#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- ord "$@"
fi

if [ "$1" = "ord" ]; then
  set -- "$1" --config "${ROOT_DIR}/configs/ord.yaml" "${@:2}"
fi

if [ "$1" = "ord" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
