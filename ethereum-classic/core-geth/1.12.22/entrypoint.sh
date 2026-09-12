#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- geth "$@"
fi

if [ "$1" = "geth" ]; then
  set -- "$1" --config="${ROOT_DIR}/configs/config.toml" "${@:2}"
fi

if [ "$1" = "geth" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
