#!/usr/bin/env bash
set -e

# Base's own /app/execution-entrypoint is entirely env-var driven and runs
# under `set -eu` - any of these left unset crashes it with an opaque "unbound
# variable" error instead of a helpful one. We only default the ones safe to
# default; BASE_NODE_L2_ENGINE_AUTH_RAW is a shared secret and gets no
# default (see error below).

# Base mainnet. Override with base-sepolia for Sepolia testnet (confirmed
# accepted values: mainnet, sepolia, zeronet, dev, base, base_sepolia,
# base-sepolia, base-zeronet).
export RETH_CHAIN="${RETH_CHAIN:-base}"

# The sequencer endpoint transactions are forwarded to. These are Base's own
# published public sequencer RPC endpoints, not secrets - override with
# --rollup.sequencer-http's env equivalent if running a private sequencer.
if [ -z "${RETH_SEQUENCER_HTTP:-}" ]; then
  case "$RETH_CHAIN" in
    base|mainnet)
      export RETH_SEQUENCER_HTTP="https://mainnet-sequencer.base.org"
      ;;
    base-sepolia|base_sepolia|sepolia)
      export RETH_SEQUENCER_HTTP="https://sepolia-sequencer.base.org"
      ;;
    *)
      echo "RETH_SEQUENCER_HTTP is required when RETH_CHAIN is not base or base-sepolia" >&2
      exit 1
      ;;
  esac
fi

# RETH_DATA_DIR is hardcoded to /data inside the upstream script itself, so
# the JWT file path defaults into the same persistent volume rather than
# somewhere that would be lost on restart.
export BASE_NODE_L2_ENGINE_AUTH="${BASE_NODE_L2_ENGINE_AUTH:-/data/jwt.hex}"

if [ -z "${BASE_NODE_L2_ENGINE_AUTH_RAW:-}" ]; then
  echo "BASE_NODE_L2_ENGINE_AUTH_RAW is required: a 64-hex-digit JWT secret shared with the paired fiftysix/base-consensus container. Generate one with: openssl rand -hex 32" >&2
  exit 1
fi

exec /app/execution-entrypoint
