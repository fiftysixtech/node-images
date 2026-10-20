#!/usr/bin/env bash
set -e

user_args=("$@")

has_flag() {
  local flag="$1" a
  for a in "${user_args[@]}"; do
    case "$a" in
      "$flag"|"$flag"=*) return 0 ;;
    esac
  done
  return 1
}

# Nitro has no bare --http/--ws toggle (confirmed: "unknown flag: --http") -
# the HTTP/WS servers are configured, not separately enabled, via their
# .addr/.port/etc sub-flags below.
defaults=()
has_flag --http.addr             || defaults+=(--http.addr 0.0.0.0)
has_flag --http.port             || defaults+=(--http.port 8547)
has_flag --http.corsdomain       || defaults+=(--http.corsdomain "*")
has_flag --http.vhosts           || defaults+=(--http.vhosts "*")
has_flag --ws.addr               || defaults+=(--ws.addr 0.0.0.0)
has_flag --ws.port               || defaults+=(--ws.port 8548)
# Arbitrum One mainnet. Override with --chain.id/--chain.name (Sepolia is
# --chain.id 421614) - has_flag only guards the ones nodevin/an operator would
# actually want to override; it is not meant to guess every network.
has_flag --chain.id              || has_flag --chain.name || defaults+=(--chain.id 42161)
# Keeps this image's data under the fiftysix mount convention (/node/nitro/data)
# instead of the base image's own default (~/.arbitrum under $HOME).
has_flag --persistent.global-config || defaults+=(--persistent.global-config "${DATA_DIR}")

# Bind mounts come in owned by whoever created the host directory - on Linux that
# is root (nodevin runs as root on a server), and the base image's uid-1000 "user"
# then cannot create anything in them: "unable to create chain directory ...
# permission denied". Docker Desktop on macOS hides this, which is why it only
# shows up on a real Linux host. So the container starts as root, fixes
# ownership of what it was given, and drops to "user" for the node itself - the
# same shape as node-base's gosu entrypoints. If it is already started as a
# non-root user (--user 1000, Kubernetes runAsNonRoot) it just runs as that user,
# and the mounts must already be writable by it.
#
# Not `chown -R` over the whole datadir on every start (as the smaller images do):
# a synced Arbitrum datadir is hundreds of GB. Only entries that are not already
# owned by "user" are fixed, recursively - normally a first start, where that is
# the (empty) mount point itself, so it costs nothing afterwards.
run_as=()
if [ "$(id -u)" = "0" ]; then
  for dir in "${DATA_DIR}" "${ROOT_DIR}/snapshot-staging"; do
    if [ -d "$dir" ]; then
      find "$dir" -maxdepth 1 ! -user user -exec chown -R user:user {} +
    fi
  done
  run_as=(setpriv --reuid=user --regid=user --init-groups env HOME=/home/user)
fi

# The base image's own ENTRYPOINT bakes these two flags in ahead of its CMD;
# overriding ENTRYPOINT here means replicating them ourselves, exactly as
# Offchain Labs' own release notes instruct, or an operator-overridden
# entrypoint would silently lose module-root validation.
exec "${run_as[@]}" /usr/local/bin/nitro \
  --validation.wasm.allowed-wasm-module-roots /home/user/nitro-legacy/machines,/home/user/target/machines \
  "${defaults[@]}" "${user_args[@]}"
