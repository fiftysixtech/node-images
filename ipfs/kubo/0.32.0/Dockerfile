FROM fiftysix/node-base:0.2.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="IPFS (Kubo) node built using the Fiftysix base image"

ARG TARGETPLATFORM
ENV NODE_VERSION="0.32.0"
ENV TARBALL_NAME="kubo_v${NODE_VERSION}"
ENV ROOT_DIR="/node/ipfs"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

# Required to properly set repo directory
ENV IPFS_PATH="${DATA_DIR}"

RUN mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}"

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        export BINARY_URL="https://github.com/ipfs/kubo/releases/download/v${NODE_VERSION}/kubo_v${NODE_VERSION}_linux-arm64.tar.gz"; \
    else \
        export BINARY_URL="https://github.com/ipfs/kubo/releases/download/v${NODE_VERSION}/kubo_v${NODE_VERSION}_linux-amd64.tar.gz"; \
    fi \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && tar -xzvf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" \
    && mv ${TMP_DIR}/kubo/ipfs /usr/bin/ \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/ipfs-entrypoint.sh"
COPY "config.conf" "${CONFIGS_DIR}/config.conf"

EXPOSE 4001 5001 8080

VOLUME ["/node/ipfs"]

ENTRYPOINT ["/node/ipfs/scripts/ipfs-entrypoint.sh"]
CMD ["ipfs", "daemon"]
