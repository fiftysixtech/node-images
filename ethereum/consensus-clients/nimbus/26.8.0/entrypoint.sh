#!/usr/bin/env bash
set -e

# unlike an execution client, nimbus must not generate its own jwt.hex - it
# has to be the exact same secret the paired execution client generated,
# shared in via a mounted volume, or the two will never authenticate with
# each other. --el/--jwt-secret are left unset below for the same reason:
# there is no correct default, since they have to point at whichever
# execution client this node is paired with.
#
# only chown nimbus's own datadir, not all of ROOT_DIR - the paired
# execution client's data/jwt is typically shared in read-only under
# ROOT_DIR too, and a blanket `chown -R` would fail on it (and, under `set
# -e`, take the whole entrypoint down with it).
chown -R nodeuser "${DATA_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- nimbus_beacon_node "$@"
fi

# unlike every other client in this repo, nimbus's (Nim/confutils) CLI only
# accepts --flag=value - a space-separated `--flag value` is silently
# misparsed as two separate tokens and fails with a confusing "does not
# accept arguments" error. Confirmed empirically. All flags below (and any
# override appended to the container's command) must use `=`.
#
# nimbus's CLI also tolerates a flag being passed twice and uses the last
# occurrence (confirmed empirically, unlike reth/lighthouse/teku), so - like
# prysm - defaults can simply be prepended here; a caller-supplied flag
# safely overrides them.
if [ "$1" = "nimbus_beacon_node" ]; then
  shift
  set -- nimbus_beacon_node \
    --non-interactive \
    --network=mainnet \
    --data-dir="${DATA_DIR}" \
    --rest=true \
    --rest-address=0.0.0.0 \
    --rest-port=5052 \
    --tcp-port=9000 \
    --udp-port=9000 \
    "$@"
fi

if [ "$1" = "nimbus_beacon_node" ]; then
  shift
  exec gosu nodeuser /usr/bin/nimbus_beacon_node "$@"
else
  exec "$@"
fi
