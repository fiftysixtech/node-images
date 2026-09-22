FROM ubuntu:24.04

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Base image for Fiftysix blockchain software using Ubuntu"

ENV DEBIAN_FRONTEND=noninteractive
ENV ROOT_DIR="/node"

ARG TARGETARCH

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
      bash \
      curl \
      tar \
      gosu \
      ca-certificates \
      openssl \
      coreutils \
      tzdata \
      ntp \
      apt-transport-https \
      software-properties-common \
    && if [ "$(uname -m)" = "aarch64" ]; then \
      echo "Building for ARM64"; \
      mkdir -p /armarmarm; \
      dpkg --add-architecture arm64; \
      apt-get update -y; \
      apt-get install -y libc6:arm64 libstdc++6:arm64; \
    else \
      echo "Not ARM64 - Skipping ARM64 libraries"; \
    fi \
    && apt-get clean \
    && service ntpsec restart \
    # Ubuntu 24.04's `ntp` package is a transitional package that installs
    # ntpsec, whose init script is registered as `ntpsec`, not `ntp`
    # (unlike on 22.04, where the `ntp` package's own init script is `ntp`)
    # The ubuntu:24.04 base image also ships a default `ubuntu` user/group at
    # UID/GID 1000 (unlike 22.04), which collides with nodeuser/nodegroup -
    # remove it so 1000 stays free and matches every other node-base version
    && userdel -r ubuntu \
    && groupadd -g 1000 nodegroup \
    && useradd -u 1000 -g nodegroup -m nodeuser \
    && mkdir -p "${ROOT_DIR}" \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

WORKDIR "${ROOT_DIR}"

CMD ["bash"]
