FROM fiftysix/node-base:0.1.1

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Bitcoin core client built using the Fiftysix base image"

ENV NODE_VERSION="27.0"
ENV TARBALL_NAME="bitcoin-${NODE_VERSION}"
ENV BINARY_URL="https://bitcoincore.org/bin/bitcoin-core-${NODE_VERSION}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz"
ENV ROOT_DIR="/node"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"

COPY "entrypoint.sh" "${ROOT_DIR}/scripts/bitcoin-core-entrypoint.sh"
COPY "config.conf" "${CONFIGS_DIR}/config.conf"

RUN curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz" \
    && tar -xzvf "${TMP_DIR}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz" -C "${TMP_DIR}" \
    && mv ${TMP_DIR}/${TARBALL_NAME}/bin/* /usr/bin/ \
    && mv ${TMP_DIR}/${TARBALL_NAME}/include/* /usr/include/ \
    && mv ${TMP_DIR}/${TARBALL_NAME}/lib/* /usr/lib/ \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

EXPOSE 8332 18332 18443 8333 18333 18444

VOLUME ["/node"]

ENTRYPOINT ["/node/scripts/bitcoin-core-entrypoint.sh"]
CMD ["bitcoind"]

