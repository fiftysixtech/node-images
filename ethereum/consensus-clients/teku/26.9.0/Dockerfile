FROM fiftysix/node-base:0.3.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum teku consensus client built using the Fiftysix base image"

# Install Java - teku's own release notes require Java 25+ ("Official builds
# of Teku are performed with Java 25. Building on a more recent version of
# Java is supported, but the resulting build will not work on earlier
# versions of Java."), so this reuses besu's existing Oracle JDK install
# pattern with the same JDK 26 version already proven in this repo.
ENV JAVA_VERSION=26
ENV JAVA_PATH_VERSION=26.0.1
ENV JAVA_URL=https://download.oracle.com/java/${JAVA_VERSION}/archive/jdk-${JAVA_PATH_VERSION}_linux-x64_bin.tar.gz
ENV JAVA_HOME=/usr/local/java/jdk-$JAVA_PATH_VERSION
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN curl -L "$JAVA_URL" -o /var/tmp/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz \
    && mkdir -p /usr/local/java \
    && tar -xzf /var/tmp/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz -C /usr/local/java \
    && rm /var/tmp/jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz

# Install teku
#
# The build-time version ENV is deliberately named TEKU_CLIENT_VERSION, not
# TEKU_VERSION - the latter collides with an env var teku's own Java code
# reads internally (undocumented, found empirically: setting TEKU_VERSION
# silently short-circuits the app into printing its version banner and
# exiting immediately, no matter what CLI flags are passed, with no error
# of any kind). besu's own Dockerfile already avoids the equivalent
# BESU_VERSION name for what may be the same reason.
ENV TEKU_CLIENT_VERSION="26.9.0"
ENV TARBALL_NAME="teku-${TEKU_CLIENT_VERSION}"
ENV RELEASE_URL="https://github.com/Consensys-Incorporated/teku/releases/download/${TEKU_CLIENT_VERSION}"
ENV BINARY_URL="${RELEASE_URL}/${TARBALL_NAME}.tar.gz"
ENV CHECKSUM_URL="${BINARY_URL}.sha256"

ENV ROOT_DIR="/node/teku"
ENV TMP_DIR="/var/tmp"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

# teku does not publish a GPG signature per release the way reth/lighthouse/
# prysm do - only an unsigned .sha256, the same situation erigon is in. This
# follows the same pattern already established for erigon: fetch and verify
# the checksum at build time so bumping TEKU_CLIENT_VERSION alone is
# sufficient.
RUN mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && mkdir -p "${ROOT_DIR}/install" \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz" \
    && curl -L "${CHECKSUM_URL}" -o "${TMP_DIR}/${TARBALL_NAME}.tar.gz.sha256" \
    && (cd "${TMP_DIR}" && sha256sum -c "${TARBALL_NAME}.tar.gz.sha256") \
    && tar -xzf "${TMP_DIR}/${TARBALL_NAME}.tar.gz" -C "${TMP_DIR}" \
    && mv "${TMP_DIR}/${TARBALL_NAME}"/* "${ROOT_DIR}/install/" \
    && rm -rf "${TMP_DIR}"/* /tmp/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/teku-entrypoint.sh"

EXPOSE 5051 9000 9000/udp

VOLUME ["/node/teku"]

ENTRYPOINT ["/node/teku/scripts/teku-entrypoint.sh"]
CMD ["teku"]
