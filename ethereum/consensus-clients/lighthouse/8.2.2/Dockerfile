FROM fiftysix/node-base:0.3.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum lighthouse consensus client built using the Fiftysix base image"

# Install lighthouse
ENV LIGHTHOUSE_VERSION="8.2.2"
ENV TARBALL_NAME="lighthouse-v${LIGHTHOUSE_VERSION}-x86_64-unknown-linux-gnu"
ENV RELEASE_URL="https://github.com/sigp/lighthouse/releases/download/v${LIGHTHOUSE_VERSION}"
ENV BINARY_URL="${RELEASE_URL}/${TARBALL_NAME}.tar.gz"
ENV SIGNATURE_URL="${BINARY_URL}.asc"

# lighthouse does not publish a checksums.txt like erigon does, only a
# detached GPG signature per asset. The fingerprint below was confirmed (via
# keyserver.ubuntu.com) to belong to "Sigma Prime <security@sigmaprime.io>",
# lighthouse's maintaining organization, and to produce a valid signature
# over the v8.2.2 release asset before being pinned here - gnupg is purged
# again after use so it isn't left in the final image.
ENV LIGHTHOUSE_SIGNING_KEY_FINGERPRINT="15E66D941F697E28F49381F426416DC3F30674B0"

ENV ROOT_DIR="/node/lighthouse"
ENV TMP_DIR="/var/tmp"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends gnupg \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && curl -L "${SIGNATURE_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz.asc" \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${LIGHTHOUSE_SIGNING_KEY_FINGERPRINT}" \
    && gpg --batch --verify "${TMP_DIR}/${TARBALL_NAME}.tar.gz.asc" "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && tar -xzf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" lighthouse \
    && mv "${TMP_DIR}/lighthouse" /usr/bin/lighthouse \
    && apt-get purge -y --auto-remove gnupg \
    && rm -rf "${TMP_DIR}"/* /tmp/* /root/.gnupg /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/lighthouse-entrypoint.sh"

EXPOSE 5052 9000 9000/udp

VOLUME ["/node/lighthouse"]

ENTRYPOINT ["/node/lighthouse/scripts/lighthouse-entrypoint.sh"]
CMD ["bn"]
