FROM ghcr.io/base/node:v1.4.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Base L2 execution client (base-reth-node), built on Base's own published image"

# Like fiftysix/nitro, this is built on the chain team's own official image
# rather than compiled from source. ghcr.io/base/node ships prebuilt
# base-reth-node and base-consensus binaries plus Base's own
# execution-entrypoint / consensus-entrypoint scripts (source:
# github.com/base/base, etc/docker/Dockerfile.rust-services - a 34-stage Rust
# build we'd otherwise reproduce for no real benefit: the published image is
# MIT licensed, already multi-arch (amd64+arm64), and only ~180MB).
#
# Base ships ONE image containing both roles (execution + consensus), started
# together under supervisord by default (see its own /etc/supervisor conf,
# baked into the image, running both `execution-entrypoint` and
# `consensus-entrypoint`). This repo instead splits it into two images -
# fiftysix/base-reth (this one) and fiftysix/base-consensus - built from the
# SAME upstream image with a different entrypoint override each, mirroring
# this repo's existing Ethereum execution/consensus pairing convention
# instead of running both roles in one container.
ENV BASE_NODE_VERSION="v1.4.2"

# Unlike every other client in this repo, this image's upstream entrypoint is
# entirely environment-variable driven: /app/execution-entrypoint takes no
# CLI flags at all (confirmed - it never references "$@", it only reads env
# vars). Our own entrypoint.sh below just sets sane defaults for the env vars
# the upstream script would otherwise crash on (`set -eu`) if left unset,
# then execs it directly. There is no has_flag-style CLI passthrough here.
USER root
COPY "entrypoint.sh" "/app/fiftysix-entrypoint.sh"
RUN chmod +x "/app/fiftysix-entrypoint.sh"

# RETH_DATA_DIR is hardcoded to /data inside the upstream execution-entrypoint
# script itself (assigned literally, not read from env) - reused as-is rather
# than fighting it or patching Base's own script, the same call made for
# Nitro's module-root flags.
VOLUME ["/data"]

# 8545 HTTP-RPC, 8546 WS-RPC, 8551 authrpc (Engine API - shared JWT with the
# paired fiftysix/base-consensus container, see docs/base.md), 6060 metrics,
# 30303 P2P (tcp+udp), 9200 discv5 (udp).
EXPOSE 8545 8546 8551 6060 30303 30303/udp 9200/udp

# The upstream image runs as root by default with no non-root user of its own
# (unlike Nitro's uid-1000 "user") - reused as-is rather than introducing
# fiftysix's usual nodeuser/gosu pattern, which belongs to node-base and has
# no part in this image.
ENTRYPOINT ["/app/fiftysix-entrypoint.sh"]
CMD []
