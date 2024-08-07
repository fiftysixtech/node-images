FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ord client built using the Fiftysix base image"

ENV ORD_VERSION="0.19.1"
ENV TARBALL_NAME="ord-${ORD_VERSION}"
ENV BINARY_URL="https://github.com/ordinals/ord/releases/download/${ORD_VERSION}/${TARBALL_NAME}-x86_64-unknown-linux-gnu.tar.gz"

ENV ROOT_DIR="/node/ord"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}-x86_64-unknown-linux-gnu.tar.gz" \
    && tar -C "${TMP_DIR}" -xzvf "${TMP_DIR}/${TARBALL_NAME}-x86_64-unknown-linux-gnu.tar.gz" \
    && mv ${TMP_DIR}/${TARBALL_NAME}/ord /usr/bin/ \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/ord-entrypoint.sh"
COPY "ord.yaml" "${CONFIGS_DIR}/ord.yaml"

EXPOSE 80

VOLUME ["/node/ord"]

ENTRYPOINT ["/node/ord/scripts/ord-entrypoint.sh"]
CMD ["ord", "server", "--http-port", "80"]

