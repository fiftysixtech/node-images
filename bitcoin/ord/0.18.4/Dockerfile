FROM fiftysix/node-base:0.1.1

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ord client built using the Fiftysix base image"

ENV ORD_VERSION="0.18.4"
ENV TARBALL_NAME="ord-${ORD_VERSION}"
ENV BINARY_URL="https://github.com/ordinals/ord/releases/download/${ORD_VERSION}/${TARBALL_NAME}-x86_64-unknown-linux-gnu.tar.gz"
ENV ROOT_DIR="/ord"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"

COPY "entrypoint.sh" "${ROOT_DIR}/scripts/ord-entrypoint.sh"
COPY "ord.yaml" "${CONFIGS_DIR}/ord.yaml"

RUN curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}-x86_64-unknown-linux-gnu.tar.gz" \
    && tar -C "${TMP_DIR}" -xzvf "${TMP_DIR}/${TARBALL_NAME}-x86_64-unknown-linux-gnu.tar.gz" \
    && mv ${TMP_DIR}/${TARBALL_NAME}/ord /usr/bin/ \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

EXPOSE 80

VOLUME ["/ord"]

ENTRYPOINT ["/ord/scripts/ord-entrypoint.sh"]
CMD ["ord", "server", "--http-port", "80"]

