#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- dogecoind "$@"
fi

if [ "$1" = "dogecoind" ] || [ "$1" = "dogecoin-cli" ]; then
  set -- "$1" -conf="${ROOT_DIR}/configs/config.conf" "${@:2}"
fi

if [ "$1" = "dogecoind" ]; then
  set -- "$@" -printtoconsole
fi

if [ "$1" = "dogecoind" ] || [ "$1" = "dogecoin-cli" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
