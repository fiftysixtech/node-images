#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  set -- ipfs-cluster-service daemon "$@"
fi

# Default behavior for IPFS Cluster if no command is provided
if [ "$1" = "ipfs-cluster-service" ]; then
  # Initialize the IPFS Cluster service if configuration does not exist
  if [ ! -f "${DATA_DIR}/service.json" ]; then
    echo "Initializing IPFS Cluster configuration..."
    # Substitute environment variables into the configuration template
    cat <<EOF > ${CONFIGS_DIR}/service.json
{
  "cluster": {
    "id": "",
    "private_key": "",
    "peername": "${CLUSTER_PEERNAME:-cluster-peer}",
    "secret": "${CLUSTER_SECRET:-}"
  },
  "addresses": {
    "api": "${API_ADDRESS:-/ip4/0.0.0.0/tcp/9094}",
    "cluster": "${CLUSTER_ADDRESS:-/ip4/0.0.0.0/tcp/9096}"
  },
  "datastore": {
    "path": "/node/ipfs-cluster/data"
  },
  "replication_factor": {
    "min": -1,
    "max": -1
  },
  "leave_on_shutdown": false,
  "log_level": "info"
}
EOF

    gosu nodeuser ipfs-cluster-service init
  fi

  # If a bootstrap address is provided, join the cluster
  if [ -n "${CLUSTER_BOOTSTRAP}" ]; then
    echo "Bootstrapping to ${CLUSTER_BOOTSTRAP}..."
    set -- "$@" --bootstrap "${CLUSTER_BOOTSTRAP}"
  else
    echo "Starting IPFS Cluster in standalone daemon mode..."
  fi
fi

# Run the specified command
if [ "$1" = "ipfs-cluster-service" ]; then
  exec gosu nodeuser "$@"
else
  exec "$@"
fi
