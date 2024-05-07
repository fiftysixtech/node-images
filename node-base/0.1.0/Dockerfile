FROM ubuntu:22.04

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Base image for Fiftysix blockchain software using Ubuntu"

ENV DEBIAN_FRONTEND=noninteractive

ENV ROOT_DIR="/node"
ENV CONFIGS_DIR="${ROOT_DIR}/configs"
ENV WALLETS_DIR="${ROOT_DIR}/wallets"
ENV LOGS_DIR="${ROOT_DIR}/logs"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"
ENV DATA_DIR="${ROOT_DIR}/data"

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
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
      software-properties-common && \
    apt-get clean

RUN service ntp restart

RUN groupadd -g 1000 nodegroup \
    && useradd -u 1000 -g nodegroup -m nodeuser \
    && mkdir -p "${ROOT_DIR}" \
    && mkdir -p "${CONFIGS_DIR}" \
    && mkdir -p "${LOGS_DIR}" \
    && mkdir -p "${WALLETS_DIR}" \
    && mkdir -p "${SCRIPTS_DIR}" \
    && chown -R nodeuser:nodegroup "${ROOT_DIR}/"

WORKDIR "${ROOT_DIR}"

VOLUME ["${CONFIGS_DIR}", "${LOGS_DIR}", "${WALLETS_DIR}", "${SCRIPTS_DIR}", "${DATA_DIR}"]

CMD ["bash"]

