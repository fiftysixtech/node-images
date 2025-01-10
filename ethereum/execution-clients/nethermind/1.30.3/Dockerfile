FROM fiftysix/node-base:0.1.2

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum Nethermind client built using the Fiftysix base image"

# Build Nethermind
ENV NETHERMIND_VERSION="1.30.3"
ENV NETHERMIND_COMMIT_HASH="87c86379"
ENV TARBALL_NAME="nethermind-${NETHERMIND_VERSION}"
ENV BINARY_URL="https://github.com/NethermindEth/nethermind/releases/download/${NETHERMIND_VERSION}/${TARBALL_NAME}-${NETHERMIND_COMMIT_HASH}-linux-x64.zip"

ENV ROOT_DIR="/node/nethermind"
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
    && mv "${TMP_DIR}"/* /usr/bin \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/nethermind-entrypoint.sh"
COPY "config.cfg" "${CONFIGS_DIR}/config.cfg"

EXPOSE 8545 8551 30303/tcp 30303/udp

VOLUME ["/node/nethermind"]

ENTRYPOINT ["/node/nethermind/scripts/nethermind-entrypoint.sh"]
CMD ["nethermind", "--datadir", "/node/nethermind/data", "--JsonRpc.JwtSecretFile", "/node/nethermind/data/jwt.hex"]
