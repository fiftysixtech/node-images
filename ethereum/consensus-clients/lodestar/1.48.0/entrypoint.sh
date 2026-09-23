#!/usr/bin/env bash
set -e

# unlike an execution client, lodestar must not generate its own jwt.hex -
# it has to be the exact same secret the paired execution client
# generated, shared in via a mounted volume, or the two will never
# authenticate with each other. --execution.urls/--jwtSecret are left
# unset below - lodestar itself defaults --execution.urls to
# http://localhost:8551, which (like prysm's equivalent default) is only
# meaningful for same-host testing; a real pairing needs it overridden to
# point at the actual execution container.
#
# only chown lodestar's own datadir, not all of ROOT_DIR - the paired
# execution client's data/jwt is typically shared in read-only under
# ROOT_DIR too, and a blanket `chown -R` would fail on it (and, under `set
# -e`, take the whole entrypoint down with it).
chown -R nodeuser "${DATA_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- beacon "$@"
fi

# lodestar's (yargs-based) CLI parses duplicated top-level scalar flags as
# last-wins, but a duplicated *dotted* flag like --rest.port is instead
# coerced into an array (confirmed empirically: --rest.port 9596
# --rest.port 9999 produces port: [9596, 9999] internally, which crashes
# the REST server with "The argument 'options' is invalid" rather than
# using either value) - a real, inconsistent-within-the-same-CLI footgun.
# The safe fix, uniformly, is to never emit a flag the caller already
# supplied, same has_flag pattern as reth/lighthouse/teku.
if [ "$1" = "beacon" ]; then
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
  has_flag --dataDir      || defaults+=(--dataDir "${DATA_DIR}")
  has_flag --rest.address || defaults+=(--rest.address 0.0.0.0)
  has_flag --rest.port    || defaults+=(--rest.port 9596)
  has_flag --port         || defaults+=(--port 9000)

  set -- beacon "${defaults[@]}" "${user_args[@]}"
fi

if [ "$1" = "beacon" ]; then
  exec gosu nodeuser lodestar "$@"
else
  exec "$@"
fi
