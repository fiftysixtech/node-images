#!/usr/bin/env bash
set -e

# add besu script to PATH
mkdir -p /etc/besu
ln -sf /node/besu/data/bin/besu /etc/besu/besu
export PATH="/etc/besu:$PATH"

# generate a new jwt file
openssl rand -hex 32 | tr -d "\n" > "/${ROOT_DIR}/data/jwt.hex"

chown -R nodeuser "${ROOT_DIR}"

if [ "$#" -eq 1 ] && [ "$1" = "besu" ]; then
  set -- "$1" --config-file="${ROOT_DIR}/configs/config.toml" "${@:2}"
fi

if [ "$1" = "besu" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
