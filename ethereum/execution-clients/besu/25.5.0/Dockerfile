FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum Besu client built using the Fiftysix base image"

# Install Java
ENV JAVA_VERSION=22
ENV JAVA_PATH_VERSION=22.0.1
ENV JAVA_URL=https://download.oracle.com/java/${JAVA_VERSION}/archive/jdk-${JAVA_PATH_VERSION}_linux-x64_bin.tar.gz
ENV JAVA_HOME=/usr/local/java/jdk-$JAVA_PATH_VERSION
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN curl -L "$JAVA_URL" -o /var/tmp/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz \
    && mkdir -p /usr/local/java \
    && tar -xzf /var/tmp/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz -C /usr/local/java \
    && rm /var/tmp/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz

# Build Besu
ENV BESU_CLIENT_VERSION="25.5.0"
ENV TARBALL_NAME="besu-${BESU_CLIENT_VERSION}"
ENV BINARY_URL="https://github.com/hyperledger/besu/releases/download/${BESU_CLIENT_VERSION}/besu-${BESU_CLIENT_VERSION}.tar.gz"

ENV ROOT_DIR="/node/besu"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN apt install libjemalloc-dev -y \
    && mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && echo "${BINARY_URL}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && tar -xzvf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" \
    && mv "${TMP_DIR}/besu-${BESU_CLIENT_VERSION}"/* "${DATA_DIR}" \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/besu-entrypoint.sh"
COPY "config.toml" "${CONFIGS_DIR}/config.toml"

EXPOSE 8545 8546 8551 30303 30303/udp

VOLUME ["/node/besu"]

ENTRYPOINT ["/node/besu/scripts/besu-entrypoint.sh"]
CMD ["besu"]
