#!/usr/bin/env bash
set -e

chown -R nodeuser "${ROOT_DIR}"

# Initialize the IPFS Cluster service with environment variables or defaults
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

  # Initialize IPFS Cluster with the generated configuration file
  gosu nodeuser ipfs-cluster-service init
fi

# If a bootstrap address is provided, join the cluster
if [ -n "${CLUSTER_BOOTSTRAP}" ]; then
  echo "Bootstrapping to ${CLUSTER_BOOTSTRAP}..."
  exec gosu nodeuser ipfs-cluster-service daemon --bootstrap "${CLUSTER_BOOTSTRAP}"
else
  # Start IPFS Cluster service as a standalone node
  echo "Starting IPFS Cluster in daemon mode..."
  exec gosu nodeuser ipfs-cluster-service daemon
fi
