## Ethereum

There are multiple networks Ethereum can sync, including:
- Ethereum mainnet
- Goerli
- Sepolia
- Holesky
- (custom network/network id)

There are also numerous ways one can sync the Ethereum blockchain's state (execution clients), in modes such as:
- snap
- full
- archive
- light (currently unavailable with `geth`)

More information on the different sync modes can be found on the [geth documentation website](https://geth.ethereum.org/docs/fundamentals/sync-modes).

**The default Fiftysix Ethereum sync is for Ethereum mainnet, in snap sync mode. This gets the user an up-and-running Ethereum node in the quickest manner possible. For other configurations, review the compose files in the `/ethereum` directory.**

### Execution Clients

There are multiple clients that can be used to track Ethereum state. More information on the clients can be found on the [Ethereum official documentation](https://ethereum.org/en/developers/docs/nodes-and-clients/#execution-clients).

#### geth

"Golang execution layer implementation of the Ethereum protocol." - [geth Github](https://github.com/ethereum/go-ethereum/tree/master)

##### JSON-RPC

The default RPC port is 8545, and can be accessed using the following requests:

```
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":83}' --url localhost:8545
```

A full list of RPC methods can be found on the [Ethereum website](https://ethereum.org/en/developers/docs/apis/json-rpc).

##### Websocket (WS)

The default WS port is 8546.

##### Flags and Configuration

For more information on flags/config settings, visit the [geth flag documentation website](https://geth.ethereum.org/docs/fundamentals/command-line-options).

#### Nethermind

"Nethermind is a high-performance, highly configurable Ethereum execution client built on .NET that runs on Linux, Windows, and macOS and supports Clique, Aura, and Ethash. With breakneck sync speeds and support for external plugins, it provides reliable access to rich on-chain data thanks to a high-performance JSON-RPC interface and node health monitoring with Grafana and Seq." - [Nethermind Github](https://github.com/NethermindEth/nethermind)

##### JSON-RPC

The default RPC port is 8545, and can be accessed using the following requests:

```
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":83}' --url localhost:8545
```

A full list of RPC methods can be found on the [Ethereum website](https://ethereum.org/en/developers/docs/apis/json-rpc).

##### Websocket (WS)

The default WS port is 8546.

##### Flags and Configuration

For more information on flags/config settings, visit the [nethermind documentation website](https://docs.nethermind.io/fundamentals/configuration).

#### besu

"Besu is an Apache 2.0 licensed, MainNet compatible, Ethereum client written in Java." - [Besu Github](https://github.com/hyperledger/besu)

##### JSON-RPC

The default RPC port is 8545, and can be accessed using the following requests:

```
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":83}' --url localhost:8545
```

A full list of RPC methods can be found on the [Ethereum website](https://ethereum.org/en/developers/docs/apis/json-rpc).

##### Websocket (WS)

The default WS port is 8546.

##### Flags and Configuration

For more information on flags/config settings, visit the [besu documentation website](https://besu.hyperledger.org/public-networks/reference/cli/options).

#### Erigon

"Erigon is an implementation of Ethereum (execution layer with embeddable consensus layer), on the efficiency frontier, written in Go." - [Erigon Github](https://github.com/erigontech/erigon)

Erigon syncs using its own staged pipeline and snapshot downloader (OtterSync), which downloads pre-verified chain segments over BitTorrent/webseed rather than a `--syncmode` flag like geth. The default Fiftysix erigon image joins Ethereum mainnet with the JSON-RPC, WS, and Engine API all enabled, and omits the `admin`/`debug` RPC namespaces by default per [erigon's own security guidance](https://docs.erigon.tech/fundamentals/security).

##### JSON-RPC

The default RPC port is 8545, and can be accessed using the following requests:

```
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":83}' --url localhost:8545
```

A full list of RPC methods can be found on the [Ethereum website](https://ethereum.org/en/developers/docs/apis/json-rpc).

##### Websocket (WS)

The default WS port is 8546.

##### Snapshot Downloader

Erigon listens on port 42069 (TCP/UDP) for its BitTorrent/webseed-based snapshot downloader (OtterSync), which is used to fetch historical chain segments instead of replaying every block from genesis. This port should be exposed alongside the standard P2P port (30303) for good sync performance. See [erigon's default ports reference](https://docs.erigon.tech/fundamentals/default-ports) for the full port list, including the internal-only ports (9090 gRPC, 8553 MCP) that should never be published outside the container.

##### Hardware Requirements

Disk and RAM needs scale with the chosen `--prune.mode`. Per [erigon's hardware requirements documentation](https://docs.erigon.tech/get-started/hardware-requirements), on Ethereum mainnet:

| Pruning Mode | Disk Size (Recommended) | RAM (Recommended) |
| --- | --- | --- |
| Full (default) | 2 TB | 32 GB |
| Minimal | 1 TB | 64 GB |
| Archive | 4 TB | 64 GB |

A locally-mounted NVMe/SSD is required — network or cloud block storage is explicitly called out as too slow for erigon's random-access workload.

##### NAT and Peering

The default image sets `nat = "none"`, which is fine for a non-validating RPC node but results in inbound-only-restricted peering (worse tx-gossip freshness). If the host has a static public IP (e.g. a VPS or datacenter box), set `nat = "extip:<your-public-ip>"` in `config.toml` for healthier peering. See [erigon's NAT documentation](https://docs.erigon.tech/fundamentals/nat) for details.

##### JWT Secret

Erigon auto-generates `jwt.hex` on first launch if it doesn't already exist at the path given to `--authrpc.jwtsecret`, and both the execution and consensus client must share that same file. The Fiftysix entrypoint only creates it when missing, so restarting the erigon container does not invalidate the paired consensus client's cached secret. See [erigon's JWT documentation](https://docs.erigon.tech/fundamentals/jwt).

##### Flags and Configuration

For more information on flags/config settings, visit the [erigon documentation website](https://docs.erigon.tech/fundamentals/configuring-erigon).

### Consensus Clients

It is also required to run a client that implements Ethereum's proof-of-stake consensus algorithm, which enables the network to achieve agreement based on validated data from the execution client. More information on this can be found on the [Ethereum officil documentation](https://ethereum.org/en/developers/docs/nodes-and-clients/#consensus-clients).

#### Prysm

"Prysm: An Ethereum Consensus Implementation Written in Go" - [Prysm Github](https://github.com/prysmaticlabs/prysm)

##### REST API

```
http://127.0.0.1:3500/eth/v1/beacon/states/finalized/root
```

More information can be found on the [Prysm documentation website](https://docs.prylabs.network/docs/how-prysm-works/ethereum-public-api).

#### Teku

"Teku is an open-source Ethereum consensus client written in Java and containing a full beacon node and validator client implementation." - [Teku Github](https://github.com/Consensys/teku)

##### REST API

```
curl -I -X GET "http://192.10.10.101:5051/teku/v1/admin/liveness"
```

More information can be found on the [official Teku documentation](https://consensys.github.io/teku/).

#### Nimbus

"Nimbus-eth2 is an extremely efficient consensus layer (eth2) client implementation. While it's optimised for embedded systems and resource-restricted devices -- including Raspberry Pis, its low resource usage also makes it an excellent choice for any server or desktop." - [Nimbus Github](https://github.com/status-im/nimbus-eth2)

##### REST API

```
curl -X GET http://localhost:5052/eth/v1/node/version
```

More information can be found on the [Nimbus documentation](https://nimbus.guide/rest-api.html#some-useful-commands).

#### Lodestar

"Lodestar is a TypeScript implementation of the Ethereum Consensus specification developed by ChainSafe Systems." - [Lodestar Github](https://github.com/ChainSafe/lodestar)

##### REST API

```
curl http://localhost:9596/eth/v1/node/version
```

More information can be found on the [Lodestar documentation](https://chainsafe.github.io/lodestar/).

#### Lighthouse

"An open-source Ethereum consensus client, written in Rust and maintained by Sigma Prime." - [Lighthouse Github](https://github.com/sigp/lighthouse)

##### REST API

```
curl http://localhost:5052/eth/v1/node/version
```

More information can be found on the [Lighthouse documentation](https://lighthouse-book.sigmaprime.io/api-bn.html).

## Other Resources

### Alternative Docker Images

#### Ethereum

eth-docker:
- [Documentation](https://eth-docker.net/)
- [Github](https://github.com/eth-educators/eth-docker)
