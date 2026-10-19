#!/usr/bin/env bash
set -e

# Base's own /app/consensus-entrypoint is entirely env-var driven and checks
# these itself, but with a generic "expected X to be set" message and no
# guidance on what X should look like. We give clearer errors up front for
# the ones this repo can't safely default.

# Base mainnet. Override with base-sepolia for Sepolia testnet - matches
# fiftysix/base-reth's RETH_CHAIN default so both sides of a pair agree
# unless explicitly overridden.
export BASE_NODE_NETWORK="${BASE_NODE_NETWORK:-base}"

if [ -z "${BASE_NODE_L1_ETH_RPC:-}" ]; then
  echo "BASE_NODE_L1_ETH_RPC is required: an Ethereum L1 execution JSON-RPC endpoint (e.g. http://reth:8545)." >&2
  exit 1
fi

if [ -z "${BASE_NODE_L1_BEACON:-}" ]; then
  echo "BASE_NODE_L1_BEACON is required: an Ethereum L1 consensus client's beacon REST API that can serve blob sidecars. See nodevin's --blob-serving flag - a default beacon node cannot serve them since the Fusaka upgrade." >&2
  exit 1
fi

if [ -z "${BASE_NODE_L2_ENGINE_RPC:-}" ]; then
  echo "BASE_NODE_L2_ENGINE_RPC is required: the paired fiftysix/base-reth container's authrpc endpoint (e.g. http://base-reth:8551)." >&2
  exit 1
fi

# Same jwt.hex path convention as fiftysix/base-reth's default, though the
# two containers never actually read each other's file - each writes its own
# local copy from BASE_NODE_L2_ENGINE_AUTH_RAW independently. Only the raw
# value has to match between them.
export BASE_NODE_L2_ENGINE_AUTH="${BASE_NODE_L2_ENGINE_AUTH:-/data/jwt.hex}"

if [ -z "${BASE_NODE_L2_ENGINE_AUTH_RAW:-}" ]; then
  echo "BASE_NODE_L2_ENGINE_AUTH_RAW is required: the same 64-hex-digit JWT secret given to the paired fiftysix/base-reth container." >&2
  exit 1
fi

exec /app/consensus-entrypoint
