FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Bitcoin core client built using the Fiftysix base image"

ENV NODE_VERSION="27.0"
ENV TARBALL_NAME="bitcoin-${NODE_VERSION}"
ENV BINARY_URL="https://bitcoincore.org/bin/bitcoin-core-${NODE_VERSION}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz"

ENV ROOT_DIR="/node/bitcoin-core"
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
    && mv ${TMP_DIR}/${TARBALL_NAME}/include/* /usr/include/ \
    && mv ${TMP_DIR}/${TARBALL_NAME}/lib/* /usr/lib/ \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/bitcoin-core-entrypoint.sh"
COPY "config.conf" "${CONFIGS_DIR}/config.conf"

EXPOSE 8332 18332 18443 8333 18333 18444

VOLUME ["/node/bitcoin-core"]

ENTRYPOINT ["/node/bitcoin-core/scripts/bitcoin-core-entrypoint.sh"]
CMD ["bitcoind"]

