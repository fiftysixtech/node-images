#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- bitcoind "$@"
fi

if [ "$1" = "bitcoind" ] || [ "$1" = "bitcoin-cli" ]; then
  set -- "$1" -conf="${ROOT_DIR}/configs/config.conf" "${@:2}"
fi

if [ "$1" = "bitcoind" ]; then
  set -- "$@" -printtoconsole
fi

if [ "$1" = "bitcoind" ] || [ "$1" = "bitcoin-cli" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
