FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum Classic coregeth client built using the Fiftysix base image"

# Install go
ENV GO_VERSION="1.22.3"
ENV GO_ROOT="/usr/local/go"
ENV PATH="${GO_ROOT}/bin:${PATH}"

RUN curl -OL "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    && echo "8920ea521bad8f6b7bc377b4824982e011c19af27df88a815e3586ea895f1b36 go${GO_VERSION}.linux-amd64.tar.gz" | sha256sum -c \
    && tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
    && rm "go${GO_VERSION}.linux-amd64.tar.gz"

# Build geth
ENV CORE_GETH_VERSION="1.12.20"
ENV TARBALL_NAME="core-geth-${CORE_GETH_VERSION}"
ENV BINARY_URL="https://github.com/etclabscore/core-geth/releases/download/v${CORE_GETH_VERSION}/core-geth-linux-v${CORE_GETH_VERSION}.zip"

ENV ROOT_DIR="/node/core-geth"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN apt-get install unzip -y \
    && mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.zip" \
    && unzip "${TMP_DIR}/${TARBALL_NAME}.zip" -d "${TMP_DIR}" \
    && mv "${TMP_DIR}/geth" /usr/bin \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/core-geth-entrypoint.sh"
COPY "config.toml" "${CONFIGS_DIR}/config.toml"

EXPOSE 8545 8546 30303 30303/udp

VOLUME ["/node/core-geth"]

ENTRYPOINT ["/node/core-geth/scripts/core-geth-entrypoint.sh"]
CMD ["geth", "--classic"]
