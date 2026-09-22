FROM fiftysix/node-base:0.3.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum nimbus consensus client built using the Fiftysix base image"

# Install nimbus
ENV NIMBUS_CLIENT_VERSION="26.8.0"
ENV TARBALL_NAME="nimbus-eth2_Linux_amd64_${NIMBUS_CLIENT_VERSION}_404a0001"
ENV RELEASE_URL="https://github.com/status-im/nimbus-eth2/releases/download/v${NIMBUS_CLIENT_VERSION}"
ENV BINARY_URL="${RELEASE_URL}/${TARBALL_NAME}.tar.gz"

ENV ROOT_DIR="/node/nimbus"
ENV TMP_DIR="/var/tmp"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

# nimbus does not publish a GPG signature or a top-level checksums file for
# the release tarball itself (unlike reth/lighthouse/prysm's GPG signatures,
# or erigon/teku's separate checksums.txt) - the only checksum available is
# a .sha512sum file bundled inside the tarball next to the binary it
# describes. Verifying against it still catches transfer corruption, but
# since both the binary and its checksum come from the same artifact, it
# adds no real protection against a tampered release the way an
# independent signature would.
RUN mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && tar -xzf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" "${TARBALL_NAME}/build/nimbus_beacon_node" "${TARBALL_NAME}/build/nimbus_beacon_node.sha512sum" \
    && (cd "${TMP_DIR}/${TARBALL_NAME}/build" && sha512sum -c nimbus_beacon_node.sha512sum) \
    && mv "${TMP_DIR}/${TARBALL_NAME}/build/nimbus_beacon_node" /usr/bin/nimbus_beacon_node \
    && rm -rf "${TMP_DIR}"/* /tmp/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/nimbus-entrypoint.sh"

EXPOSE 5052 9000 9000/udp 9001/udp

VOLUME ["/node/nimbus"]

ENTRYPOINT ["/node/nimbus/scripts/nimbus-entrypoint.sh"]
CMD ["nimbus_beacon_node"]
