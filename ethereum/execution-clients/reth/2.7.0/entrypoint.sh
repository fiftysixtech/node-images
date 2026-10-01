#!/usr/bin/env bash
set -e

# only generate a jwt secret if one doesn't already exist - regenerating it on
# every restart would invalidate the paired consensus client's cached secret
if [ ! -f "${ROOT_DIR}/data/jwt.hex" ]; then
  openssl rand -hex 32 | tr -d "\n" > "${ROOT_DIR}/data/jwt.hex"
fi

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- node "$@"
fi

# unlike erigon/besu/nethermind, reth's own --config file only covers
# staged-sync/db/prune settings - it does not accept RPC, networking, or
# authrpc settings, so those are passed as CLI flags here instead of via a
# checked-in config file. reth's arg parser errors ("cannot be used multiple
# times") if a flag is passed twice, so each default below is only added
# when the caller hasn't already supplied that flag themselves.
if [ "$1" = "node" ]; then
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
  has_flag --chain               || defaults+=(--chain mainnet)
  has_flag --datadir             || defaults+=(--datadir "${ROOT_DIR}/data")
  has_flag --http                || defaults+=(--http)
  has_flag --http.addr           || defaults+=(--http.addr 0.0.0.0)
  has_flag --http.port           || defaults+=(--http.port 8545)
  has_flag --http.api            || defaults+=(--http.api eth,net,web3,trace,txpool,reth)
  has_flag --ws                  || defaults+=(--ws)
  has_flag --ws.addr             || defaults+=(--ws.addr 0.0.0.0)
  has_flag --ws.port             || defaults+=(--ws.port 8546)
  has_flag --ws.api              || defaults+=(--ws.api eth,net,web3,trace,txpool,reth)
  has_flag --authrpc.addr        || defaults+=(--authrpc.addr 0.0.0.0)
  has_flag --authrpc.port        || defaults+=(--authrpc.port 8551)
  has_flag --authrpc.jwtsecret   || defaults+=(--authrpc.jwtsecret "${ROOT_DIR}/data/jwt.hex")
  has_flag --port                || defaults+=(--port 30303)
  has_flag --nat                 || defaults+=(--nat none)

  set -- node "${defaults[@]}" "${user_args[@]}"
fi

if [ "$1" = "node" ]; then
  exec gosu nodeuser reth "$@"
else
  exec "$@"
fi
