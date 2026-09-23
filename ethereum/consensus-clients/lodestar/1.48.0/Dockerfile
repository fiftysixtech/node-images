FROM fiftysix/node-base:0.3.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum lodestar consensus client built using the Fiftysix base image"

# Install lodestar
#
# The build-time version ENV is deliberately NOT named LODESTAR_* - lodestar
# itself (yargs' built-in .env() prefix matching) treats any LODESTAR_*
# environment variable as an implicit CLI flag override. LODESTAR_CLIENT_
# VERSION (matching this repo's usual <CLIENT>_CLIENT_VERSION convention,
# adopted specifically to dodge teku's equivalent collision) gets mapped to
# a nonexistent --clientVersion flag and hard-fails every invocation of
# `lodestar beacon` with "Unknown argument: clientVersion" - found
# empirically (confirmed by unsetting the var, which fixed it). This is a
# second, different flavor of the same class of bug teku's TEKU_VERSION
# hit: worth checking for on any future Java/Node-based client image added
# to this repo.
ENV CLIENT_VERSION="1.48.0"
ENV TARBALL_NAME="lodestar-v${CLIENT_VERSION}-linux-amd64"
ENV RELEASE_URL="https://github.com/ChainSafe/lodestar/releases/download/v${CLIENT_VERSION}"
ENV BINARY_URL="${RELEASE_URL}/${TARBALL_NAME}.tar.gz"

ENV ROOT_DIR="/node/lodestar"
ENV TMP_DIR="/var/tmp"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

# unlike every other client image in this repo, lodestar publishes no
# checksum and no signature of any kind for its release tarball - not even
# an unsigned one bundled inside it (nimbus's situation). There is nothing
# independent to verify the download against, so - like besu/nethermind -
# no verification step is performed here. This is a real gap, not an
# oversight; flagged here and in docs/ethereum.md rather than silently
# matching the stronger-verification clients' Dockerfile shape without the
# substance.
#
# lodestar's binary requires glibc 2.39/libstdc++ 3.4.31 (confirmed: fails
# on node-base:0.2.0/ubuntu:22.04 with a GLIBCXX_3.4.31 not found error,
# the same class of failure reth hit), hence node-base:0.3.0.
RUN mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && tar -xzf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" lodestar \
    && mv "${TMP_DIR}/lodestar" /usr/bin/lodestar \
    && rm -rf "${TMP_DIR}"/* /tmp/*.tar.gz \
    # lodestar's binary is a self-extracting bundle (caxa) that unpacks its
    # ~130MB bundled Node runtime into /tmp/caxa on first run. Since that's
    # a plain directory, running --version once here bakes the
    # already-extracted cache into the image layer, so every container
    # start skips that unpack step (confirmed: the "Unpacking Lodestar
    # binary" message never appears again after this). This does not make
    # startup instant - Node.js still takes several seconds to boot this
    # large a bundle regardless - it just avoids re-paying the extraction
    # itself on every single container start/restart.
    && /usr/bin/lodestar --version \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/" \
    && chown -R nodeuser:nodegroup /tmp/caxa

COPY "entrypoint.sh" "${SCRIPTS_DIR}/lodestar-entrypoint.sh"

EXPOSE 9596 9000 9000/udp

VOLUME ["/node/lodestar"]

ENTRYPOINT ["/node/lodestar/scripts/lodestar-entrypoint.sh"]
CMD ["beacon"]
