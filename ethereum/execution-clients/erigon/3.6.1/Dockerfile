FROM fiftysix/node-base:0.2.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum erigon client built using the Fiftysix base image"

# Install erigon
ENV ERIGON_VERSION="3.6.1"
ENV TARBALL_NAME="erigon_v${ERIGON_VERSION}_linux_amd64"
ENV RELEASE_URL="https://github.com/erigontech/erigon/releases/download/v${ERIGON_VERSION}"
ENV BINARY_URL="${RELEASE_URL}/${TARBALL_NAME}.tar.gz"
ENV CHECKSUMS_URL="${RELEASE_URL}/erigon_v${ERIGON_VERSION}_checksums.txt"

ENV ROOT_DIR="/node/erigon"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

# The erigon release checksum is fetched and verified at build time (rather
# than pinned as a literal ENV) so that bumping ERIGON_VERSION alone is
# always sufficient - no separate checksum update step to keep in sync.
RUN mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && curl -L "${CHECKSUMS_URL}" -o "${TMP_DIR}/checksums.txt" \
    && grep -E " ${TARBALL_NAME}\.tar\.gz\$" "${TMP_DIR}/checksums.txt" > "${TMP_DIR}/checksum.txt" \
    && (cd "${TMP_DIR}" && sha256sum -c checksum.txt) \
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
