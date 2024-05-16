#!/usr/bin/env bash
set -e

# generate a new jwt file
openssl rand -hex 32 | tr -d "\n" > "/${ROOT_DIR}/data/jwt.hex"

chown -R nodeuser "${ROOT_DIR}"

if [ "$1" = "data/bin/besu" ]; then
  set -- "$1" --config-file="${ROOT_DIR}/configs/config.toml" "${@:2}"
fi

if [ "$1" = "data/bin/besu" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
