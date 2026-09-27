## BNB Smart Chain

BNB Smart Chain (BSC) is an EVM-compatible chain using Parlia, a Proof-of-Staked-Authority consensus mechanism. This repo publishes `fiftysix/bsc`, built from [bnb-chain/bsc](https://github.com/bnb-chain/bsc)'s own prebuilt release binary.

### What is BSC?

BSC is a fork of go-ethereum - its `go.mod` module path is still literally `github.com/ethereum/go-ethereum` - with the Parlia consensus engine built directly into the same binary. Unlike every Ethereum client in this repo, there is no execution/consensus split, no Engine API, and no JWT secret: `fiftysix/bsc` is a single monolithic process, closer in shape to Nitro than to geth/reth/besu/nethermind/erigon, even though it's built the normal way (from source/binary, on `fiftysix/node-base`) rather than on an official upstream image.

### Why this image downloads a prebuilt binary instead of compiling from source

Every other geth-family client in this repo (`geth`, `core-geth`) either compiles from source or downloads a prebuilt archive. `fiftysix/bsc` downloads `bnb-chain/bsc`'s own prebuilt, statically-linked Linux binary (published directly with every release, no zip) and verifies it against a sha256sum pinned in the Dockerfile. **Note:** bnb-chain/bsc does not publish an official checksums file alongside its releases (confirmed - no `.sha256`/`checksums.txt` asset exists), so the pinned value is this image's own first-recorded checksum for that release, not one verified against an independently-published upstream value. It still protects against a corrupted download or the file changing after this image was built.

### Two networks, one image

Unlike this repo's Ethereum images, BSC has no built-in chain configuration nodevin can select with a plain `--networkid`/`--chain` flag - it must be initialised from a genesis file first. This image bundles **both** mainnet and testnet (Chapel) `genesis.json`/`config.toml` pairs, taken directly from `bnb-chain/bsc`'s own published release bundles (`mainnet.zip`/`testnet.zip` on each GitHub release), and the entrypoint picks between them via a `NETWORK` environment variable (`mainnet` or `testnet`, default `mainnet`) - not a CLI flag, since there's no CLI flag for this on the upstream binary either.

On first start (no `chaindata` directory yet), the entrypoint runs `geth init` against the matching bundled genesis file automatically - no manual init step is needed.

### A real gotcha in the upstream config, fixed here

BNB Chain's own published `config.toml` files set `HTTPHost`/`WSHost` to `localhost`/`127.0.0.1` - fine for a bare-metal box, but this only accepts connections from *inside* the container. Confirmed by reading both the mainnet and testnet bundles directly (not assumed): both need `HTTPHost`/`WSHost` overridden to `0.0.0.0` for the exposed Docker ports to actually work, which this image's bundled config.toml files do.

### Ports

- **8545**: HTTP-RPC
- **8546**: WS-RPC
- **30311** (tcp+udp): P2P - BSC's own default, not Ethereum's usual 30303

Testnet's own published config additionally uses different RPC ports (`8575`/`8576`) from mainnet's `8545`/`8546` - normalized to `8545`/`8546` in both of this image's bundled configs so mainnet and testnet behave identically from the outside; only `NetworkId`, the genesis file, and the bootnode list actually differ between them internally.

### Snapshot Downloading

Syncing from genesis is impractical - per [BNB Chain's own snapshot repo](https://github.com/bnb-chain/bsc-snapshots), a full snapshot needs roughly 8 TB free (or 7 TB with `--auto-delete`), a pruned snapshot roughly 2 TB. Download and extract with their `fetch-snapshot.sh` script into the mounted data volume before starting the container; not yet automated by this image (see Known Gaps).

### Hardware Requirements

Per [BNB Chain's snapshot repo](https://github.com/bnb-chain/bsc-snapshots) and third-party operator guides ([chaingateway.io](https://chaingateway.io/bsc-node/)):

| Item | Full node | Archive node |
| --- | --- | --- |
| CPU | 16+ cores | 16+ cores |
| RAM | 64 GB | 128 GB |
| Disk | NVMe, ~3 TB (pruned snapshot ~0.9-1.7 TB + growth) | NVMe, ~10 TB (archive snapshot ~5-7 TB) |

BSC produces blocks roughly every 0.45-0.75 seconds depending on the active hardfork, so sustained write IOPS matters as much as raw capacity - BNB Chain's own reference spec targets 8,000+ provisioned IOPS.

### Flags and Configuration

For the full flag reference, run `docker run --rm fiftysix/bsc --help`, or see [BNB Chain's own node operator docs](https://docs.bnbchain.org/bnb-smart-chain/developers/node_operators/full_node/).

### Known Gaps (as of this image's first version)

- No real sync has been attempted against real chain data; only genesis initialisation and startup were verified.
- Snapshot downloading is documented but not automated by this image - an operator (or nodevin, later) must run `fetch-snapshot.sh` into the mounted volume themselves.
- Not yet wired into nodevin.
