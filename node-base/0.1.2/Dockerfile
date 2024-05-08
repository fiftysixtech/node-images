FROM ubuntu:22.04

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Base image for Fiftysix blockchain software using Ubuntu"

ENV DEBIAN_FRONTEND=noninteractive

ENV ROOT_DIR="/node"

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
    && apt-get clean \
    && service ntp restart \
    && groupadd -g 1000 nodegroup \
    && useradd -u 1000 -g nodegroup -m nodeuser \
    && mkdir -p "${ROOT_DIR}" \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

WORKDIR "${ROOT_DIR}"

CMD ["bash"]

