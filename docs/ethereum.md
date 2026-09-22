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

#### Reth

"Reth (short for Rust Ethereum) is a new Ethereum full node implementation that is focused on being user-friendly, highly modular, as well as being fast and efficient." - [Reth Github](https://github.com/paradigmxyz/reth)

Reth is maintained by [Paradigm](https://www.paradigm.xyz/) and is also the execution client that Base's own node image is built on. Unlike geth, erigon, besu, and nethermind, reth does not accept RPC/networking/authrpc settings through a checked-in config file - its own `--config` flag only covers staged-sync/database/prune settings. The Fiftysix entrypoint instead passes the standard set of flags (chain, HTTP, WS, Engine API, networking) directly on the command line, and only applies a default for a given flag if the caller hasn't already supplied it themselves - so any flag can still be overridden by appending it to the container's command.

##### JSON-RPC

The default RPC port is 8545, and can be accessed using the following requests:

```
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":83}' --url localhost:8545
```

A full list of RPC methods can be found on the [Ethereum website](https://ethereum.org/en/developers/docs/apis/json-rpc).

##### Websocket (WS)

The default WS port is 8546.

##### Hardware Requirements

Per [reth's system requirements documentation](https://reth.rs/run/system-requirements), for an Ethereum mainnet node:

| Mode | Disk (Recommended) | RAM (Recommended) |
| --- | --- | --- |
| Full node | 1.2 TB+ (TLC NVMe) | 8 GB+ |
| Archive node | 2.8 TB+ (TLC NVMe) | 16 GB+ |

A TLC (not QLC) NVMe drive is recommended - reth's own documentation notes disk is by far the most important requirement, with CPU/RAM being comparatively flexible.

##### JWT Secret

Reth auto-generates `jwt.hex` on first launch if it doesn't already exist at the path given to `--authrpc.jwtsecret`, and both the execution and consensus client must share that same file. The Fiftysix entrypoint only creates it when missing, so restarting the reth container does not invalidate the paired consensus client's cached secret.

##### Binary Verification

Reth doesn't publish a `checksums.txt` alongside its releases the way erigon does - only a detached GPG signature per release asset. The Fiftysix image verifies the downloaded binary against that signature using Paradigm's published signing key at build time.

##### Flags and Configuration

For more information on flags/config settings, visit the [reth CLI reference](https://reth.rs/cli/reth/node) and the [reth documentation website](https://reth.rs).

### Consensus Clients

It is also required to run a client that implements Ethereum's proof-of-stake consensus algorithm, which enables the network to achieve agreement based on validated data from the execution client. More information on this can be found on the [Ethereum officil documentation](https://ethereum.org/en/developers/docs/nodes-and-clients/#consensus-clients).

#### Prysm

"Prysm: An Ethereum Consensus Implementation Written in Go" - [Prysm Github](https://github.com/prysmaticlabs/prysm)

Prysm's own GitHub org is [OffchainLabs/prysm](https://github.com/OffchainLabs/prysm) (formerly under prysmaticlabs, which now redirects). Like Lighthouse, Prysm can't run standalone and requires pairing with an execution client - see [Pairing with an execution client](#pairing-with-an-execution-client) under Lighthouse above for the general JWT-sharing approach, which applies here too via `--execution-endpoint`/`--jwt-secret`.

A couple of differences from Lighthouse worth calling out for anyone extending this image:
- Prysm requires `--accept-terms-of-use` or it blocks waiting for an interactive prompt and fails fast once it detects no TTY - the Fiftysix entrypoint always passes this.
- Unlike Lighthouse/Reth's CLI, Prysm's CLI tolerates a flag being passed twice and uses the last occurrence, so the entrypoint doesn't need Lighthouse's "only default a flag if the caller hasn't set it" logic - defaults are simply prepended and any caller-supplied flag safely overrides them.
- This was also verified end-to-end locally against `fiftysix/reth`, the same way as Lighthouse: `execution: Connected to new endpoint endpoint=http://reth-node:8551`, followed by real `initial-sync: Processing blocks` progress.

##### REST API

The default HTTP API port is 3500, and can be accessed using the following requests:

```
curl http://127.0.0.1:3500/eth/v1/beacon/states/finalized/root
```

More information can be found on the [Prysm documentation website](https://docs.prylabs.network/docs/how-prysm-works/ethereum-public-api).

##### P2P Networking

Prysm listens on TCP port 13000 (libp2p) and UDP port 12000 (discv5) by default.

##### Binary Verification

Prysm publishes both a `.sha256` and a detached GPG `.sig` per release asset. Since the `.sha256` file is unsigned and comes from the same channel as the binary itself, the Fiftysix image verifies the GPG signature instead, pinned to a Prysm core maintainer's published signing key.

##### Flags and Configuration

For more information on flags/config settings, run `beacon-chain --help` or visit the [Prysm documentation website](https://docs.prylabs.network/).

#### Teku

"Teku is an open-source Ethereum consensus client written in Java and containing a full beacon node and validator client implementation." - [Teku Github](https://github.com/Consensys-Incorporated/teku)

Teku's GitHub org moved to [Consensys-Incorporated/teku](https://github.com/Consensys-Incorporated/teku) (the old `Consensys/teku` link redirects), and its docs moved to [docs.teku.consensys.io](https://docs.teku.consensys.io/) (the old `consensys.github.io/teku` link is now dead - both corrected here). Like Lighthouse/Prysm, Teku can't run standalone and requires pairing with an execution client - see [Pairing with an execution client](#pairing-with-an-execution-client) under Lighthouse above for the general JWT-sharing approach; here it's `--ee-endpoint`/`--ee-jwt-secret-file`.

Teku is a Java client and requires a JDK at runtime, using the same Oracle JDK 26 install already established for Besu in this repo (Teku's own release notes require Java 25+).

**A real, non-obvious bug found and fixed while building this image:** the Dockerfile's build-time version `ENV` was originally named `TEKU_VERSION`, matching the naming convention every other client Dockerfile in this repo uses (`ERIGON_VERSION`, `RETH_VERSION`, etc.). That name collides with an env var Teku's own Java code reads internally and undocumented - setting it silently short-circuits the app into printing its version banner and exiting immediately, no matter what CLI flags are passed, with no error of any kind. Confirmed empirically (unsetting it restored normal startup). Renamed to `TEKU_CLIENT_VERSION`, matching Besu's own Dockerfile, which already avoids the equivalent `BESU_VERSION` name - possibly for the same reason.

##### REST API

The default REST API port is 5051, and can be accessed using the following requests:

```
curl -I -X GET "http://127.0.0.1:5051/teku/v1/admin/liveness"
```

More information can be found in the [Teku REST API reference](https://docs.teku.consensys.io/reference/rest).

##### P2P Networking

Teku listens on port 9000 (TCP/UDP) for its P2P connections by default.

##### Binary Verification

Teku doesn't publish a GPG signature per release the way Reth/Lighthouse/Prysm do - only an unsigned `.sha256`, the same situation Erigon is in. The Fiftysix image follows the same pattern already established for Erigon: the checksum is fetched and verified at build time.

##### Flags and Configuration

For more information on flags/config settings, run `teku --help` or visit the [Teku user documentation](https://docs.teku.consensys.io/).

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

Lighthouse currently has the largest share of Ethereum mainnet consensus client traffic. Unlike an execution client, a consensus client cannot run standalone - the Fiftysix image does not (and cannot) supply defaults for `--execution-endpoint` or `--execution-jwt`, since those have to point at whichever execution client this node is paired with. Lighthouse's own CLI enforces `--execution-endpoint` as required and will fail immediately with a clear error if it isn't supplied.

##### Pairing with an execution client

- `--execution-endpoint` must be set to the paired execution client's Engine API URL (e.g. `http://<execution-service-name>:8551`).
- `--execution-jwt` must point at the *same* `jwt.hex` file the execution client generated - it has to be shared in via a mounted volume (e.g. mounting the execution client's data volume, or just the `jwt.hex` file, read-only into the Lighthouse container). Lighthouse does not generate its own JWT secret the way an execution client does, since generating an independent one would silently produce a mismatched secret.
- This was verified end-to-end locally: a `fiftysix/reth` container and a `fiftysix/lighthouse` container on a shared Docker network, with reth's data volume mounted read-only into the Lighthouse container and `--execution-jwt` pointed at the shared `jwt.hex`, successfully authenticated and began pulling real execution payloads from reth (`Sync state updated ... new_state: Syncing Finalized Chain`).

##### Checkpoint Sync

By default Lighthouse refuses to sync from genesis (`Syncing from genesis is insecure and incompatible with data availability checks`) unless `--allow-insecure-genesis-sync` is explicitly passed, which is not recommended. For a practical, fast sync, pass `--checkpoint-sync-url <URL>` pointing at a trusted checkpoint sync provider - see the [public endpoint list](https://eth-clients.github.io/checkpoint-sync-endpoints/). The Fiftysix image intentionally does not bake in a default third-party checkpoint sync endpoint.

##### REST API

The default HTTP API port is 5052, and can be accessed using the following requests:

```
curl http://localhost:5052/eth/v1/node/version
```

More information can be found on the [Lighthouse documentation](https://lighthouse-book.sigmaprime.io/api-bn.html).

##### P2P Networking

Lighthouse listens on port 9000 (TCP/UDP) for its libp2p peer connections by default.

##### Binary Verification

Lighthouse doesn't publish a `checksums.txt` alongside its releases - only a detached GPG signature per release asset. The Fiftysix image verifies the downloaded binary against that signature using Sigma Prime's published signing key at build time.

##### Flags and Configuration

For more information on flags/config settings, run `lighthouse bn --help` or visit the [Lighthouse book](https://lighthouse-book.sigmaprime.io/).

## Other Resources

### Alternative Docker Images

#### Ethereum

eth-docker:
- [Documentation](https://eth-docker.net/)
- [Github](https://github.com/eth-educators/eth-docker)
