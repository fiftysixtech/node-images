#!/usr/bin/env bash
set -e

# add besu script to PATH
mkdir -p /etc/besu
ln -sf /node/besu/data/bin/besu /etc/besu/besu
export PATH="/etc/besu:$PATH"

# only generate a jwt secret if one doesn't already exist - regenerating it on
# every restart would invalidate the paired consensus client's cached secret
if [ ! -f "${ROOT_DIR}/data/jwt.hex" ]; then
  openssl rand -hex 32 | tr -d "\n" > "${ROOT_DIR}/data/jwt.hex"
fi

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- besu "$@"
fi

if [ "$1" = "besu" ]; then
  set -- "$1" --config-file="${ROOT_DIR}/configs/config.toml" "${@:2}"
fi

if [ "$1" = "besu" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
