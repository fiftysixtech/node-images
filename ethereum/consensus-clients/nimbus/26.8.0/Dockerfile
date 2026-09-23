FROM fiftysix/node-base:0.3.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum nimbus consensus client built using the Fiftysix base image"

# Install nimbus
#
# nimbus's release asset filenames embed a build-specific commit hash (e.g.
# nimbus-eth2_Linux_amd64_26.8.0_404a0001.tar.gz) that changes every release
# and can't be derived from the version number alone. This Dockerfile used
# to hardcode that hash directly in TARBALL_NAME, which meant a version bump
# alone was never sufficient - the hash also had to be looked up and updated
# by hand, and a naive automated version bump (this repo's
# createNewDockerfile.sh does a plain string substitution of the version
# only) would silently produce a URL for a release asset that doesn't
# exist - nethermind hit the identical problem for the identical reason
# (see that Dockerfile's git history). Resolved dynamically instead via the
# GitHub Releases API, filtering on the parts of the filename that ARE
# stable (starts with "nimbus-eth2_Linux_amd64_", ends with ".tar.gz") -
# bumping NIMBUS_CLIENT_VERSION alone is sufficient again, same as every
# other client in this repo.
ENV NIMBUS_CLIENT_VERSION="26.8.0"
ENV RELEASE_API_URL="https://api.github.com/repos/status-im/nimbus-eth2/releases/tags/v${NIMBUS_CLIENT_VERSION}"

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
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends jq \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && BINARY_URL=$(curl -s "${RELEASE_API_URL}" | jq -r '.assets[] | select(.name | startswith("nimbus-eth2_Linux_amd64_") and endswith(".tar.gz")) | .browser_download_url') \
    && TARBALL_FILENAME=$(basename "${BINARY_URL}") \
    && TARBALL_NAME="${TARBALL_FILENAME%.tar.gz}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_FILENAME}" \
    && tar -xzf "${TMP_DIR}/${TARBALL_FILENAME}" -C "${TMP_DIR}" "${TARBALL_NAME}/build/nimbus_beacon_node" "${TARBALL_NAME}/build/nimbus_beacon_node.sha512sum" \
    && (cd "${TMP_DIR}/${TARBALL_NAME}/build" && sha512sum -c nimbus_beacon_node.sha512sum) \
    && mv "${TMP_DIR}/${TARBALL_NAME}/build/nimbus_beacon_node" /usr/bin/nimbus_beacon_node \
    && apt-get purge -y --auto-remove jq \
    && rm -rf "${TMP_DIR}"/* /tmp/* /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/nimbus-entrypoint.sh"

EXPOSE 5052 9000 9000/udp 9001/udp

VOLUME ["/node/nimbus"]

ENTRYPOINT ["/node/nimbus/scripts/nimbus-entrypoint.sh"]
CMD ["nimbus_beacon_node"]
