FROM fiftysix/node-base:0.2.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="IPFS Cluster node built from source using the Fiftysix base image"

# Set up arguments and environment variables
ARG TARGETPLATFORM
ENV CLUSTER_REPO="https://github.com/ipfs-cluster/ipfs-cluster.git"
ENV CLUSTER_VERSION="v1.1.2"
ENV GO_VERSION="1.23.2"
ENV ROOT_DIR="/node/ipfs-cluster"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"
ENV GOPATH="/go"

# Set IPFS Cluster path
ENV IPFS_CLUSTER_PATH="${DATA_DIR}"

# Configurable env variables for IPFS Cluster setup
ENV CLUSTER_SECRET=""
ENV CLUSTER_PEERNAME="cluster-peer"
ENV CLUSTER_BOOTSTRAP=""
ENV API_ADDRESS="/ip4/0.0.0.0/tcp/9094"
ENV CLUSTER_ADDRESS="/ip4/0.0.0.0/tcp/9096"

# Install Git, Go, and Make
RUN apt-get update && apt-get install git make -y \
    && curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    && tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
    && rm "go${GO_VERSION}.linux-amd64.tar.gz" \
    && ln -s /usr/local/go/bin/go /usr/bin/go \
    && ln -s /usr/local/go/bin/gofmt /usr/bin/gofmt

# Clone the specific tag from the IPFS Cluster repository
RUN mkdir -p "${CONFIGS_DIR}" "${SCRIPTS_DIR}" "${DATA_DIR}" "${GOPATH}/bin" \
    && git clone --branch "${CLUSTER_VERSION}" --depth 1 "${CLUSTER_REPO}" "${TMP_DIR}/ipfs-cluster" \
    && cd "${TMP_DIR}/ipfs-cluster" \
    && make install \
    && cp ${GOPATH}/bin/ipfs-cluster-service /usr/local/bin/ \
    && cp ${GOPATH}/bin/ipfs-cluster-ctl /usr/local/bin/ \
    && cp ${GOPATH}/bin/ipfs-cluster-follow /usr/local/bin/ \
    && rm -rf "${TMP_DIR}"/*

COPY "entrypoint.sh" "${SCRIPTS_DIR}/cluster-entrypoint.sh"

EXPOSE 9094 9096

VOLUME ["/node/ipfs-cluster"]

ENTRYPOINT ["/node/ipfs-cluster/scripts/cluster-entrypoint.sh"]
CMD ["ipfs-cluster-service", "daemon"]
