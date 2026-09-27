#!/usr/bin/env bash
set -e

# BSC (mainnet) or BSC Chapel (testnet). Selects which bundled
# genesis.json/config.toml pair under ${CONFIGS_DIR} to use - there is no
# public flag for this, so nodevin (or you) chooses by setting this env var,
# not a CLI flag.
NETWORK="${NETWORK:-mainnet}"
if [ "$NETWORK" != "mainnet" ] && [ "$NETWORK" != "testnet" ]; then
  echo "NETWORK must be \"mainnet\" or \"testnet\", got: ${NETWORK}" >&2
  exit 1
fi

NETWORK_CONFIG_DIR="${CONFIGS_DIR}/${NETWORK}"
CONFIG_FILE="${NETWORK_CONFIG_DIR}/config.toml"
GENESIS_FILE="${NETWORK_CONFIG_DIR}/genesis.json"

chown -R nodeuser "${ROOT_DIR}"

# geth refuses to start against a datadir with no chain database at all, and
# a plain --networkid/--chain flag isn't enough for BSC (there's no built-in
# chain config for it, unlike Ethereum mainnet/Sepolia) - it has to be
# initialised from the matching genesis file first. Only do this once: an
# existing chaindata directory means a real, possibly-synced database is
# already there.
if [ ! -d "${DATA_DIR}/geth/chaindata" ]; then
  gosu nodeuser geth --datadir "${DATA_DIR}" init "${GENESIS_FILE}"
fi

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- geth "$@"
fi

if [ "$1" = "geth" ]; then
  set -- "$1" --config="${CONFIG_FILE}" "${@:2}"
fi

if [ "$1" = "geth" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
