#!/usr/bin/env bash
set -e

# unlike an execution client, prysm must not generate its own jwt.hex - it
# has to be the exact same secret the paired execution client generated,
# shared in via a mounted volume, or the two will never authenticate with
# each other. --execution-endpoint/--jwt-secret are left unset below for
# the same reason: there is no correct default, since they have to point at
# whichever execution client this node is paired with.
#
# only chown prysm's own datadir, not all of ROOT_DIR - the paired
# execution client's data/jwt is typically shared in read-only under
# ROOT_DIR too, and a blanket `chown -R` would fail on it (and, under `set
# -e`, take the whole entrypoint down with it).
chown -R nodeuser "${DATA_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- beacon-chain "$@"
fi

# --accept-terms-of-use is required in a non-interactive environment like a
# container - without it, prysm blocks on stdin waiting for an interactive
# "accept"/"decline" prompt and fails fast once it finds no TTY.
#
# unlike reth/lighthouse's clap-based CLI, prysm's (urfave/cli) tolerates a
# flag being passed twice and uses the last occurrence, so - unlike those
# two entrypoints - the defaults below can simply be prepended: any
# matching flag the caller supplies afterward safely overrides it.
if [ "$1" = "beacon-chain" ]; then
  shift
  set -- beacon-chain \
    --accept-terms-of-use \
    --mainnet \
    --datadir "${DATA_DIR}" \
    --http-host 0.0.0.0 \
    --http-port 3500 \
    --p2p-tcp-port 13000 \
    --p2p-udp-port 12000 \
    "$@"
fi

if [ "$1" = "beacon-chain" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
