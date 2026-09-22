FROM fiftysix/node-base:0.3.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum prysm consensus client built using the Fiftysix base image"

# Install prysm
ENV PRYSM_VERSION="7.1.8"
ENV BINARY_NAME="beacon-chain-v${PRYSM_VERSION}-linux-amd64"
ENV RELEASE_URL="https://github.com/OffchainLabs/prysm/releases/download/v${PRYSM_VERSION}"
ENV BINARY_URL="${RELEASE_URL}/${BINARY_NAME}"
ENV SIGNATURE_URL="${BINARY_URL}.sig"

# prysm publishes both a .sha256 and a detached (binary, non-ASCII-armored)
# GPG .sig per release asset. The sha256 file is unsigned and comes from the
# same channel as the binary itself, so it adds no real authenticity
# guarantee beyond plain integrity - the GPG signature is verified instead,
# pinned to the fingerprint confirmed (via keyserver.ubuntu.com) to belong
# to "Preston Van Loon <preston@prysmaticlabs.com>", a Prysm core
# maintainer, and to produce a valid signature over the v7.1.8 release
# asset before being pinned here. gnupg is purged again after use so it
# isn't left in the final image.
ENV PRYSM_SIGNING_KEY_FINGERPRINT="0AE0051D647BA3C1A917AF4072E33E4DF1A5036E"

ENV ROOT_DIR="/node/prysm"
ENV TMP_DIR="/var/tmp"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends gnupg \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${BINARY_NAME}" \
    && curl -L "${SIGNATURE_URL}" -o "${TMP_DIR}/${BINARY_NAME}.sig" \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${PRYSM_SIGNING_KEY_FINGERPRINT}" \
    && gpg --batch --verify "${TMP_DIR}/${BINARY_NAME}.sig" "${TMP_DIR}/${BINARY_NAME}" \
    && mv "${TMP_DIR}/${BINARY_NAME}" /usr/bin/beacon-chain \
    && chmod +x /usr/bin/beacon-chain \
    && apt-get purge -y --auto-remove gnupg \
    && rm -rf "${TMP_DIR}"/* /tmp/* /root/.gnupg /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/prysm-entrypoint.sh"

EXPOSE 3500 12000/udp 13000

VOLUME ["/node/prysm"]

ENTRYPOINT ["/node/prysm/scripts/prysm-entrypoint.sh"]
CMD ["beacon-chain"]
