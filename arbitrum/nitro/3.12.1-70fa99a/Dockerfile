FROM offchainlabs/nitro-node:v3.12.1-70fa99a

LABEL maintainer="nodes@fiftysix.xyz"
LABEL description="Arbitrum Nitro node, built on Offchain Labs' own published image"

# Unlike every other client in this repo, Nitro is not built from source here.
# Its build is a 20+ stage Go/Rust/WASM toolchain that ends by downloading
# dozens of historical "consensus machine" WASM binaries pinned to on-chain
# module-root hashes, and validating the freshly-compiled prover against them
# (see Dockerfile stages `module-root-calc`/`machine-versions` and
# `validate-wasm-module-root.sh` in github.com/OffchainLabs/nitro). Offchain
# Labs' own official Dockerfile even builds FROM a past official release image
# (offchainlabs/nitro-node:v3.7.6-c0fe95e) to source machine files it can no
# longer regenerate standalone. Reproducing that independently risks getting a
# validator/prover mismatch wrong in a way that is invisible until it matters;
# building on their published image guarantees the module roots match what the
# network expects. Nitro is licensed under the Business Source License 1.1
# (LICENSE.md in the source repo), not the permissive licenses the other
# clients in this repo use - confirm the license terms fit your use before
# distributing this image further.
ENV NITRO_VERSION="3.12.1-70fa99a"

ENV ROOT_DIR="/node/nitro"
ENV DATA_DIR="${ROOT_DIR}/data"
ENV SCRIPTS_DIR="${ROOT_DIR}/scripts"

# The base image already runs as a non-root user ("user", uid 1000) with
# HOME=/home/user - reused as-is rather than introducing fiftysix's usual
# nodeuser/gosu pattern, which belongs to node-base and has no part in this
# image.
USER root
RUN mkdir -p "${DATA_DIR}" "${SCRIPTS_DIR}" \
    && chown -R user:user "${ROOT_DIR}"

COPY "entrypoint.sh" "${SCRIPTS_DIR}/nitro-entrypoint.sh"
RUN chmod +x "${SCRIPTS_DIR}/nitro-entrypoint.sh"

# 8547 HTTP-RPC, 8548 WS-RPC, 9642 sequencer feed relay. Nitro has no
# Engine-API/JWT split of its own - it is a single monolithic node - so unlike
# the Ethereum L1 images there is no auth port and no JWT secret to generate.
EXPOSE 8547 8548 9642

VOLUME ["/node/nitro"]

USER user
ENTRYPOINT ["/node/nitro/scripts/nitro-entrypoint.sh"]
CMD []
