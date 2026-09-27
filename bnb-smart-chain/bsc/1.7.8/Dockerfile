FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="BNB Smart Chain (BSC) client built using the Fiftysix base image"

# BSC is a geth fork - its own go.mod is still literally
# "github.com/ethereum/go-ethereum" - with a Parlia (PoSA) consensus engine
# built in and no separate execution/consensus split, no Engine API, and no
# JWT secret of its own, unlike every Ethereum client in this repo.
#
# Unlike geth/core-geth's own Dockerfiles in this repo, this one does not
# compile from source: bnb-chain/bsc publishes a prebuilt, statically-linked
# Linux binary with every release (no separate checksums file is published,
# so the sha256sum below is this image's own first-recorded value for this
# release, not a value confirmed against an upstream-published checksum -
# pinned so a corrupted or altered download fails the build rather than
# silently shipping).
ENV BSC_VERSION="1.7.8"
ENV BINARY_URL="https://github.com/bnb-chain/bsc/releases/download/v${BSC_VERSION}/geth_linux"
ENV BINARY_SHA256="28466c6b6b279e2026ddcfea09ddadd920d2bcf02efab3c854e4bb0d5a3ae534"

ENV ROOT_DIR="/node/bsc"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${CONFIGS_DIR}" "${SCRIPTS_DIR}" "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o /usr/bin/geth \
    && echo "${BINARY_SHA256}  /usr/bin/geth" | sha256sum -c \
    && chmod +x /usr/bin/geth \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/bsc-entrypoint.sh"
RUN chmod +x "${SCRIPTS_DIR}/bsc-entrypoint.sh"

# Bundles BOTH mainnet and testnet (Chapel) genesis.json/config.toml, taken
# from bnb-chain/bsc's own published release bundles (mainnet.zip/
# testnet.zip) with HTTPHost/WSHost overridden from upstream's
# localhost/127.0.0.1 default to 0.0.0.0 - see each config.toml's own
# comments. entrypoint.sh picks between them via the NETWORK env var.
COPY "config/mainnet/genesis.json" "${CONFIGS_DIR}/mainnet/genesis.json"
COPY "config/mainnet/config.toml" "${CONFIGS_DIR}/mainnet/config.toml"
COPY "config/testnet/genesis.json" "${CONFIGS_DIR}/testnet/genesis.json"
COPY "config/testnet/config.toml" "${CONFIGS_DIR}/testnet/config.toml"
RUN chown -R nodeuser:nodegroup "${CONFIGS_DIR}"

# 8545 HTTP-RPC, 8546 WS-RPC (normalized for both networks - see
# config/testnet/config.toml's comment), 30311 P2P (BSC's own default,
# distinct from Ethereum's 30303).
EXPOSE 8545 8546 30311 30311/udp

VOLUME ["/node/bsc"]

ENTRYPOINT ["/node/bsc/scripts/bsc-entrypoint.sh"]
CMD ["geth"]
