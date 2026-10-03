#!/usr/bin/env bash
set -e

# only generate a jwt secret if one doesn't already exist - regenerating it on
# every restart would invalidate the paired consensus client's cached secret
if [ ! -f "${ROOT_DIR}/data/jwt.hex" ]; then
  openssl rand -hex 32 | tr -d "\n" > "${ROOT_DIR}/data/jwt.hex"
fi

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- nethermind "$@"
fi

if [ "$1" = "nethermind" ]; then
  set -- "$1" --config "${ROOT_DIR}/configs/config.cfg" "${@:2}"
fi

if [ "$1" = "nethermind" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
