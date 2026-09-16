FROM fiftysix/node-base:0.2.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum erigon client built using the Fiftysix base image"

# Install erigon
ENV ERIGON_VERSION="3.6.1"
ENV TARBALL_NAME="erigon_v${ERIGON_VERSION}_linux_amd64"
ENV BINARY_URL="https://github.com/erigontech/erigon/releases/download/v${ERIGON_VERSION}/${TARBALL_NAME}.tar.gz"
ENV BINARY_SHA256="175ee2eaea718d52d4226903d84faa8b5fbeac98b2504d352db03a512f5418e4"

ENV ROOT_DIR="/node/erigon"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && echo "${BINARY_SHA256}  ${TMP_DIR}/${TARBALL_NAME}.tar.gz" | sha256sum -c \
    && tar -xzf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" "${TARBALL_NAME}/erigon" \
    && mv "${TMP_DIR}/${TARBALL_NAME}/erigon" /usr/bin/erigon \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/erigon-entrypoint.sh"
COPY "config.toml" "${CONFIGS_DIR}/config.toml"

EXPOSE 8545 8546 8551 30303 30303/udp 42069 42069/udp

VOLUME ["/node/erigon"]

# erigon's own upstream Dockerfile pins this to SIGINT rather than the
# default SIGTERM, so `docker stop` triggers a clean MDBX shutdown instead
# of a forced SIGKILL after the grace period
STOPSIGNAL SIGINT

ENTRYPOINT ["/node/erigon/scripts/erigon-entrypoint.sh"]
CMD ["erigon"]
