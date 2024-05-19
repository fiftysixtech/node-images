FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Litecoin core client built using the Fiftysix base image"

ENV NODE_VERSION="0.21.3"
ENV TARBALL_NAME="litecoin-${NODE_VERSION}"
ENV BINARY_URL="https://github.com/litecoin-project/litecoin/releases/download/v${NODE_VERSION}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz"

ENV ROOT_DIR="/node/litecoin-core"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz" \
    && tar -xzvf "${TMP_DIR}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz" -C "${TMP_DIR}" \
    && mv ${TMP_DIR}/${TARBALL_NAME}/bin/* /usr/bin/ \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/litecoin-core-entrypoint.sh"
COPY "config.conf" "${CONFIGS_DIR}/config.conf"

EXPOSE 9332 9333 19332 19333 19444

VOLUME ["/node/litecoin-core"]

ENTRYPOINT ["/node/litecoin-core/scripts/litecoin-core-entrypoint.sh"]
CMD ["litecoind"]

