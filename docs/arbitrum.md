## Arbitrum

Arbitrum is an Optimistic Rollup Layer 2 built on Ethereum, developed by Offchain Labs. This repo publishes `fiftysix/nitro`, built on top of Offchain Labs' own official `offchainlabs/nitro-node` Docker image rather than compiled from source. See [Ethereum](./ethereum.md) for the L1 execution/consensus images an Arbitrum node depends on, and [Ethereum Execution/Consensus Pairing](./ethereum-execution-consensus-pairing.md) for the JWT-sharing mechanism between them.

### Why this image is built differently from every other image in this repo

Every other client here is compiled from source on top of `fiftysix/node-base`. Nitro is the one exception, for a reason specific to it, not a change in policy:

Nitro's own build is a 20+ stage Go/Rust/WASM toolchain ([`OffchainLabs/nitro`](https://github.com/OffchainLabs/nitro)'s `Dockerfile`) that ends by downloading dozens of historical "consensus machine" WASM binaries, each pinned to a specific on-chain module-root hash, and validating the freshly-compiled prover against them (`validate-wasm-module-root.sh`). These module roots are what the network's fraud-proof system checks a validator's computation against. Offchain Labs' own official Dockerfile builds *from a past official release image* (`offchainlabs/nitro-node:v3.7.6-c0fe95e`) to source machine files for older consensus versions it can no longer regenerate standalone — a strong signal that reproducing this independently, correctly, is hard even for the people who wrote it. Building on their published image guarantees the module roots match what the network expects, and their image is already multi-arch (amd64 + arm64), unlike every execution/consensus client image in this repo's Ethereum family.

### License

Nitro is licensed under the [Business Source License 1.1](https://github.com/OffchainLabs/nitro/blob/master/LICENSE.md), not the permissive licenses (Apache/MIT/LGPL) the rest of this repo's clients use. The license's Additional Use Grant appears to cover running a node against Arbitrum's own chains (interacting with, querying, or validating a Covered Arbitrum Chain). Confirm this fits your use before distributing the image further; it converts to Apache 2.0 on 2030-12-31.

### Nitro

"Arbitrum Nitro is the software that powers Arbitrum chains, including Arbitrum One... it combines the security benefits of Ethereum's Geth client with the speed and cost efficiency of Optimistic Rollups." — [Arbitrum docs](https://docs.arbitrum.io/)

Unlike every Ethereum consensus/execution image in this repo, Nitro is a single monolithic process: there is no separate execution/consensus split, no Engine API, and no JWT secret of its own. It connects directly to an Ethereum L1 over plain JSON-RPC for execution data, and to an L1 beacon node's REST API for blob data. Confirmed empirically: pointing `--parent-chain.connection.url` at a plain (non-authenticated) L1 JSON-RPC endpoint works with no JWT configured at all.

#### Parent Chain (L1) Requirement

Nitro needs two things from Ethereum L1:

- `--parent-chain.connection.url`: an execution JSON-RPC endpoint (e.g. `http://reth:8545`).
- `--parent-chain.blob-client.beacon-url`: a consensus client's beacon REST API that can serve blob sidecars (e.g. `http://lighthouse:5052`).

Since the Fusaka upgrade (PeerDAS), a default L1 consensus client cannot serve blob sidecars at all — see nodevin's `--blob-serving` flag (added specifically for this) and the "Blob dependency" section below. `--parent-chain.id` should be set to the L1 chain ID (`1` for mainnet, `11155111` for Sepolia) so Nitro can validate it is talking to the right chain.

There is no `--parent-chain.connection.jwtsecret` requirement for a plain RPC URL; that flag exists for cases (`self`/`self-auth`) not relevant to a normal external L1 node.

#### JSON-RPC

The default RPC port is 8547 (not 8545 — Nitro's own default, distinct from every L1 execution client in this repo):

```
curl -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' --url localhost:8547
```

#### Websocket (WS)

The default WS port is 8548.

#### Sequencer Feed

Port 9642 relays the sequencer feed (real-time pending transaction/block data broadcast by the sequencer) to other nodes.

#### Chain Selection

`--chain.id` alone resolves Arbitrum's built-in chain configuration for known networks — no genesis file needed. Confirmed: `--chain.id 421614` (Arbitrum Sepolia) correctly resolved the real rollup contract address with nothing else supplied. Arbitrum One mainnet is `--chain.id 42161`.

#### Snapshot Downloader / Init Flow

Official snapshots are published at [snapshot.arbitrum.foundation](https://snapshot.arbitrum.foundation), with pointer files (`arb1/latest-pruned.txt`, `arb1/latest-full-path.txt`) naming the current directory. Rather than downloading and extracting manually (fragile - the directory/manifest layout is only documented for one snapshot kind), let Nitro resolve and apply it itself:

```
--init.latest pruned --init.then-quit
```

This downloads, verifies (`--init.validate-checksum`, on by default) and initialises, then exits. `--init.latest` also accepts `archive` and `genesis`. Not yet verified end-to-end in this repo (see Known Gaps below).

#### Blob Dependency and Backfill

An Arbitrum node reads the blobs its batches were posted in from the L1 beacon node. A **freshly started** blob-serving L1 consensus client only has blobs from around when it started, not from before — confirmed empirically (see nodevin's `--blob-serving` documentation): after 30 minutes, a fresh node had no blocks a full day back, let alone the ~18-day blob retention window. Since an Arbitrum node restored from a snapshot needs blobs from the snapshot's date forward, **start the L1 consensus client well ahead of the Arbitrum node**, or use a rented blob endpoint while it catches up.

#### Hardware Requirements

Per the Fiftysix internal cost analysis (Fiftysix Infrastructure Strategy & Arbitrum Node Test, 2026-09-26) and [Arbitrum's own docs](https://docs.arbitrum.io/run-arbitrum-node/run-full-node):

| Item | Requirement |
| --- | --- |
| CPU | 8+ cores |
| RAM | 16 GB minimum, 32 GB comfortable |
| Disk | NVMe; ~1.1 TB snapshot to download, ~2.3 TB after initialisation (pruned) |
| Growth | ~50-80 GB/month (pruned) |
| Egress | Estimated 1-3 TB/month for the L2 node itself (separate from the L1's own egress - see [Ethereum](./ethereum.md) for the cost of a blob-serving L1) |

#### Flags and Configuration

For the full flag reference, run `docker run --rm fiftysix/nitro --help`, or see the [CLI flags reference](https://docs.arbitrum.io/run-arbitrum-node/nitro/cli-flags-reference) and [optional parameters](https://docs.arbitrum.io/run-arbitrum-node/partials/run-full-node/_optional-parameters) on Arbitrum's own docs.

#### Known Gaps (as of this image's first version)

- No real sync has been run against this image yet. A connectivity test against a real Sepolia L1 confirmed Nitro connects over plain JSON-RPC and resolves chain config correctly, but a full snapshot-init sync (`--init.latest pruned --init.then-quit`) has not been attempted, nor has blob fetching been exercised end-to-end.
- Not run on mainnet.
- Not yet wired into nodevin.
