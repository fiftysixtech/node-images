# Ethereum Classic

This document provides setup and usage instructions for running an Ethereum Classic node using Core-Geth with Docker. The official Docker image can be found on the [Fiftysix Core-Geth Docker Hub](https://hub.docker.com/r/fiftysix/core-geth).

## Core-Geth

"An ethereum/go-ethereum downstream effort to make the Ethereum Protocol accessible and extensible for a diverse ecosystem." - [CoreGeth Github](github.com/etclabscore/core-geth)

## Setting Up Ethereum Classic Node

### Pull the Docker Image

To get started, pull the latest Core-Geth image from Docker Hub:

```bash
docker pull fiftysix/core-geth:latest
```

### Running the Node

You can run an Ethereum Classic node using the following Docker command:

```bash
docker run -d --name ethereum-classic-node \
  -p 30303:30303 \
  -v /path/to/your/data:/root/.ethereum-classic \
  fiftysix/core-geth:latest
```

- `-d`: Runs the container in detached mode.
- `-p 30303:30303`: Maps the Ethereum Classic network port to your local machine.
- `-v /path/to/your/data:/root/.ethereum-classic`: Mounts a volume on your machine to persist blockchain data.

### JSON-RPC

The Core-Geth Ethereum Classic node exposes a JSON-RPC interface on the default port `8545`. You can interact with the node using the following command:

```bash
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":83}' --url http://localhost:8545
```

A full list of RPC methods is available in the [Ethereum JSON-RPC documentation](https://ethereumclassic.org/development/eth-rpc-api).

## Additional Resources

- [Core-Geth Documentation](https://github.com/etclabscore/core-geth)
- [Ethereum Classic Website](https://ethereumclassic.org/)
- [Ethereum JSON-RPC API](https://ethereumclassic.org/development/eth-rpc-api)
