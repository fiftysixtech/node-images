#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- ipfs daemon "$@"
fi

if [ "$1" = "ipfs" ] && [ "$2" = "daemon" ]; then
  # Create the repo on first start. An existing repo from an older kubo has to
  # be migrated before `ipfs config` will touch it (it is a no-op when current).
  if [ ! -f "${IPFS_PATH}/config" ]; then
    gosu nodeuser ipfs init
  else
    gosu nodeuser ipfs repo migrate
  fi

  # Kubo binds the RPC API and gateway to 127.0.0.1 by default, which is
  # unreachable through a published container port. Bind them on all container
  # interfaces like the official image does. Applied on every start so the
  # values can be changed by setting these variables; publish the ports on
  # 127.0.0.1 only (the API has admin-level access to the node).
  gosu nodeuser ipfs config Addresses.API "${IPFS_API_ADDRESS:-/ip4/0.0.0.0/tcp/5001}"
  gosu nodeuser ipfs config Addresses.Gateway "${IPFS_GATEWAY_ADDRESS:-/ip4/0.0.0.0/tcp/8080}"

  set -- "$1" "$2" --migrate "${@:3}"
elif [ "$1" = "ipfs" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi

exec gosu nodeuser "$@"
