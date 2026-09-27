FROM ghcr.io/base/node:v1.4.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Base L2 consensus (rollup) client (base-consensus), built on Base's own published image"

# See fiftysix/base-reth's Dockerfile for why this is built on Base's own
# official image and why this repo splits it into two images instead of
# running both roles in the one upstream image under supervisord.
ENV BASE_NODE_VERSION="v1.4.2"

# Same as fiftysix/base-reth: /app/consensus-entrypoint is entirely
# env-var driven and takes no CLI flags at all (confirmed - it never
# references "$@"). Our entrypoint.sh only defaults env vars safe to
# default; the L1/L2 endpoints and shared JWT get no default.
USER root
COPY "entrypoint.sh" "/app/fiftysix-entrypoint.sh"
RUN chmod +x "/app/fiftysix-entrypoint.sh"

# Unlike base-reth-node, base-consensus has no --datadir/--state-dir flag at
# all (confirmed via --help): it's a largely stateless derivation pipeline
# (OP-stack op-node lineage) reading from L1 + the paired L2 execution
# client, not a chain database of its own. This volume only persists the
# optional p2p private key (--p2p.priv.path) and admin-state file, so a
# restart keeps the same peer identity instead of re-announcing as a new one.
VOLUME ["/data"]

# 9545 RPC (BASE_NODE_RPC_PORT default), 9222 P2P TCP (libp2p), 9223 P2P
# discovery UDP (discv5), 9090 Prometheus metrics. Confirmed via
# `base-consensus node --help` - these differ from earlier assumptions
# (7545/9222/7300): read the real --help output, don't guess from OP-stack's
# op-node defaults.
EXPOSE 9545 9222 9223/udp 9090

# Same as fiftysix/base-reth - the upstream image runs as root with no
# non-root user of its own; reused as-is.
ENTRYPOINT ["/app/fiftysix-entrypoint.sh"]
CMD []
