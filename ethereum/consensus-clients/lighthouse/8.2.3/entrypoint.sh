#!/usr/bin/env bash
set -e

# unlike an execution client, lighthouse must not generate its own jwt.hex -
# it has to be the exact same secret the paired execution client generated,
# shared in via a mounted volume, or the two will never authenticate with
# each other. --execution-endpoint/--execution-jwt are left unset below for
# the same reason: there is no correct default, since they have to point at
# whichever execution client this node is paired with.
#
# only chown lighthouse's own datadir, not all of ROOT_DIR - the paired
# execution client's data/jwt is typically shared in read-only under
# ROOT_DIR too, and a blanket `chown -R` would fail on it (and, under `set
# -e`, take the whole entrypoint down with it).
chown -R nodeuser "${DATA_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- bn "$@"
fi

# lighthouse's own --config file only covers a small subset of settings and
# does not accept RPC/networking/execution-layer settings, so those are
# passed as CLI flags here instead of via a checked-in config file. Like
# reth, lighthouse's arg parser errors ("cannot be used multiple times") if
# a flag is passed twice, so each default below is only added when the
# caller hasn't already supplied that flag themselves.
if [ "$1" = "bn" ]; then
  shift
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

  defaults=()
  has_flag --network      || defaults+=(--network mainnet)
  has_flag --datadir      || defaults+=(--datadir "${ROOT_DIR}/data")
  has_flag --http         || defaults+=(--http)
  has_flag --http-address || defaults+=(--http-address 0.0.0.0)
  has_flag --http-port    || defaults+=(--http-port 5052)
  has_flag --port         || defaults+=(--port 9000)

  set -- bn "${defaults[@]}" "${user_args[@]}"
fi

if [ "$1" = "bn" ]; then
  exec gosu nodeuser lighthouse "$@"
else
  exec "$@"
fi
