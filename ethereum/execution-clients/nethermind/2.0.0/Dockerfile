FROM fiftysix/node-base:0.2.0

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Ethereum Nethermind client built using the Fiftysix base image"

# Install Nethermind
ENV NETHERMIND_VERSION="2.0.0"
ENV RELEASE_API_URL="https://api.github.com/repos/NethermindEth/nethermind/releases/tags/${NETHERMIND_VERSION}"

# nethermind's release asset filenames embed a build-specific commit hash
# (e.g. nethermind-2.0.0-bec830cd-linux-x64.zip) that changes every release
# and can't be derived from the version number alone. Previously this
# Dockerfile hardcoded that hash as a separate NETHERMIND_COMMIT_HASH env
# var, which meant a version bump alone was never sufficient - the hash also
# had to be looked up and updated by hand, and a naive automated version
# bump (bumping NETHERMIND_VERSION only) would silently produce a URL for a
# release asset that doesn't exist. Resolved dynamically instead via the
# GitHub Releases API, filtering on the one part of the filename that IS
# stable (the "linux-x64.zip" suffix) - bumping NETHERMIND_VERSION alone is
# sufficient again, same as every other client in this repo.
#
# nethermind's release signature is now verified too (previously this image
# had no verification at all) - the fingerprint below was confirmed (via
# keyserver.ubuntu.com) to belong to "Nethermind <devops@nethermind.io>" and
# to produce a valid signature over the 2.0.0 release asset before being
# pinned here.
ENV NETHERMIND_SIGNING_KEY_FINGERPRINT="AD1279765093C6759CD8A40024A774616F1E617E"

ENV ROOT_DIR="/node/nethermind"
ENV TMP_DIR="/var/tmp"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends unzip jq gnupg \
    && mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && mkdir -p "${DATA_DIR}" \
    && BINARY_URL=$(curl -s "${RELEASE_API_URL}" | jq -r '.assets[] | select(.name | endswith("linux-x64.zip")) | .browser_download_url') \
    && curl -L "${BINARY_URL}" -o "${TMP_DIR}/nethermind.zip" \
    && curl -L "${BINARY_URL}.asc" -o "${TMP_DIR}/nethermind.zip.asc" \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${NETHERMIND_SIGNING_KEY_FINGERPRINT}" \
    && gpg --batch --verify "${TMP_DIR}/nethermind.zip.asc" "${TMP_DIR}/nethermind.zip" \
    && unzip "${TMP_DIR}/nethermind.zip" -d "${TMP_DIR}/extracted" \
    && mv "${TMP_DIR}/extracted"/* /usr/bin \
    && apt-get purge -y --auto-remove unzip jq gnupg \
    && rm -rf "${TMP_DIR}"/* /tmp/* /root/.gnupg /var/lib/apt/lists/* \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/nethermind-entrypoint.sh"
COPY "config.cfg" "${CONFIGS_DIR}/config.cfg"

EXPOSE 8545 8551 30303/tcp 30303/udp

VOLUME ["/node/nethermind"]

ENTRYPOINT ["/node/nethermind/scripts/nethermind-entrypoint.sh"]
CMD ["nethermind", "--datadir", "/node/nethermind/data", "--JsonRpc.JwtSecretFile", "/node/nethermind/data/jwt.hex"]
