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

# The base image's own ENTRYPOINT bakes these two flags in ahead of its CMD;
# overriding ENTRYPOINT here means replicating them ourselves, exactly as
# Offchain Labs' own release notes instruct, or an operator-overridden
# entrypoint would silently lose module-root validation.
exec /usr/local/bin/nitro \
  --validation.wasm.allowed-wasm-module-roots /home/user/nitro-legacy/machines,/home/user/target/machines \
  "${defaults[@]}" "${user_args[@]}"
