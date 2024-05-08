FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum geth client built using the Fiftysix base image"

# install go
ENV GO_VERSION="1.22.3"
ENV GOROOT="/usr/local/go"
ENV PATH="${GOROOT}/bin:${PATH}"

RUN curl -OL "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    && echo "8920ea521bad8f6b7bc377b4824982e011c19af27df88a815e3586ea895f1b36 go${GO_VERSION}.linux-amd64.tar.gz" | sha256sum -c \
    && tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    #&& echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/.profile \
    #&& . "$HOME/.profile"

# build geth
ENV GETH_VERSION="1.14.2"
ENV TARBALL_NAME="geth-${GETH_VERSION}"
ENV BINARY_URL="https://github.com/ethereum/go-ethereum/archive/refs/tags/v${GETH_VERSION}.tar.gz"

ENV ROOT_DIR="/node/geth"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && tar -xzvf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" \
    && cd "${TMP_DIR}/go-ethereum-${GETH_VERSION}" \
    && ls -la \
    && go run build/ci.go install -static ./cmd/geth \
    && cp build/bin/geth /usr/bin \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/geth-entrypoint.sh"
COPY "config.toml" "${CONFIGS_DIR}/config.toml"

EXPOSE 8545 8546 30303 30303/udp

VOLUME ["/node/geth"]

ENTRYPOINT ["/node/geth/scripts/geth-entrypoint.sh"]
CMD ["geth"]
