#!/usr/bin/env bash
set -e

# generate a new jwt file
openssl rand -hex 32 | tr -d "\n" > "/${ROOT_DIR}/data/jwt.hex"

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- nethermind "$@"
fi

if [ "$1" = "geth" ]; then
  set -- "$1" --config "${ROOT_DIR}/configs/config.cfg" "${@:2}"
fi

if [ "$1" = "geth" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
