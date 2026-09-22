#!/usr/bin/env bash
set -e

# unlike an execution client, teku must not generate its own jwt.hex - it
# has to be the exact same secret the paired execution client generated,
# shared in via a mounted volume, or the two will never authenticate with
# each other. --ee-endpoint/--ee-jwt-secret-file are left unset below for
# the same reason: there is no correct default, since they have to point at
# whichever execution client this node is paired with.
#
# only chown teku's own datadir, not all of ROOT_DIR - the paired execution
# client's data/jwt is typically shared in read-only under ROOT_DIR too,
# and a blanket `chown -R` would fail on it (and, under `set -e`, take the
# whole entrypoint down with it).
chown -R nodeuser "${DATA_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- teku "$@"
fi

# like reth/lighthouse's CLI (and unlike prysm's), teku's picocli-based CLI
# errors ("should be specified only once") if a flag is passed twice, so
# each default below is only added when the caller hasn't already supplied
# that flag themselves.
if [ "$1" = "teku" ]; then
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
  has_flag --network                 || defaults+=(--network mainnet)
  has_flag --data-path                || defaults+=(--data-path "${DATA_DIR}")
  has_flag --rest-api-enabled         || defaults+=(--rest-api-enabled=true)
  has_flag --rest-api-interface       || defaults+=(--rest-api-interface 0.0.0.0)
  has_flag --rest-api-port            || defaults+=(--rest-api-port 5051)
  has_flag --rest-api-host-allowlist  || defaults+=(--rest-api-host-allowlist "*")
  has_flag --p2p-port                 || defaults+=(--p2p-port 9000)

  set -- teku "${defaults[@]}" "${user_args[@]}"
fi

if [ "$1" = "teku" ]; then
  shift
  exec gosu nodeuser "${ROOT_DIR}/install/bin/teku" "$@"
else
  exec "$@"
fi
