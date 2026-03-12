#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- ipfs daemon "$@"
fi

if [ "$1" = "ipfs" ] && [ "$2" = "daemon" ]; then
  set -- "$1" "$2" --config "${CONFIGS_DIR}/config.conf" --init --migrate "${@:3}"
elif [ "$1" = "ipfs" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi

exec gosu nodeuser "$@"
