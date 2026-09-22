FROM fiftysix/node-base:0.3.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum reth client built using the Fiftysix base image"

# Install reth
ENV RETH_VERSION="2.6.0"
ENV TARBALL_NAME="reth-v${RETH_VERSION}-x86_64-unknown-linux-gnu"
ENV RELEASE_URL="https://github.com/paradigmxyz/reth/releases/download/v${RETH_VERSION}"
ENV BINARY_URL="${RELEASE_URL}/${TARBALL_NAME}.tar.gz"
ENV SIGNATURE_URL="${BINARY_URL}.asc"

# reth does not publish a checksums.txt like erigon does, only a detached GPG
# signature per asset. The fingerprint below was confirmed (via
# keyserver.ubuntu.com) to belong to "Georgios Konstantopoulos (Reth signing
# key for 2024 and on) <georgios@paradigm.xyz>" and to produce a valid
# signature over the v2.6.0 release asset before being pinned here - gnupg is
# purged again after use so it isn't left in the final image.
ENV RETH_SIGNING_KEY_FINGERPRINT="50FB7CC55B2E8AFA59FE03B7AA5ED56A7FBF253E"

ENV ROOT_DIR="/node/reth"
ENV TMP_DIR="/var/tmp"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends gnupg \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && curl -L "${SIGNATURE_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz.asc" \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${RETH_SIGNING_KEY_FINGERPRINT}" \
    && gpg --batch --verify "${TMP_DIR}/${TARBALL_NAME}.tar.gz.asc" "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && tar -xzf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" reth \
    && mv "${TMP_DIR}/reth" /usr/bin/reth \
    && apt-get purge -y --auto-remove gnupg \
    && rm -rf "${TMP_DIR}"/* /tmp/* /root/.gnupg /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/reth-entrypoint.sh"

EXPOSE 8545 8546 8551 30303 30303/udp

VOLUME ["/node/reth"]

ENTRYPOINT ["/node/reth/scripts/reth-entrypoint.sh"]
CMD ["node"]
