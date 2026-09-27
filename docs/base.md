## Base

Base is an Optimistic Rollup Layer 2 built on Ethereum, incubated by Coinbase and built on the OP Stack. This repo publishes two images, `fiftysix/base-reth` (execution) and `fiftysix/base-consensus` (rollup/consensus), both built on top of Base's own official `ghcr.io/base/node` Docker image rather than compiled from source. See [Ethereum](./ethereum.md) for the L1 execution/consensus images a Base node depends on, [Ethereum Execution/Consensus Pairing](./ethereum-execution-consensus-pairing.md) for this repo's existing JWT-sharing conventions, and [Arbitrum](./arbitrum.md) for the same "build on the official image" decision made for a different L2.

### Why this is two images, both built differently from most clients in this repo

Base ships as **one** upstream image (`ghcr.io/base/node`) containing prebuilt `base-reth-node` (execution) and `base-consensus` (rollup/consensus) binaries, started together under `supervisord` by default - unlike every other client in this repo, and unlike Nitro (which is one monolithic process). Its source, [`base/base`](https://github.com/base/base) (the current repo - `base/node` is archived and redirects here), builds both from a 34-stage Rust Dockerfile (`etc/docker/Dockerfile.rust-services`).

This repo does two things differently than the upstream default:

1. **Builds on the official image rather than from source**, for the same reason as Nitro: no correctness-critical reason not to (Base is [MIT licensed](https://github.com/base/base/blob/main/LICENSE), confirmed directly from the repo - unlike Nitro's BSL 1.1), and the official image is already multi-arch (amd64 + arm64, confirmed via `docker manifest inspect`) and small (~360MB uncompressed for the base image itself before any data).
2. **Splits it into two separate images and containers** instead of running both roles in one container via `supervisord`. Base's architecture - a separate execution client and rollup/consensus client talking over the Engine API with a shared JWT - is structurally identical to this repo's existing Ethereum execution/consensus pairing, and splitting it lets each role be resourced, restarted, and updated independently, matching that existing convention instead of introducing a new one.

Splitting is possible because the upstream image's own `/app/execution-entrypoint` and `/app/consensus-entrypoint` scripts (the two scripts `supervisord` runs together by default) work perfectly well run standalone - confirmed by running each in its own container against a real Base Sepolia L1 (see Test Plan below).

### Configuration model: environment variables, not CLI flags

Unlike every other client in this repo, `execution-entrypoint` and `consensus-entrypoint` are **entirely environment-variable driven** - confirmed by reading both scripts: neither references `"$@"` anywhere, so passing extra CLI arguments to either has no effect at all. There is no `has_flag`-style CLI passthrough in `fiftysix/base-reth`'s or `fiftysix/base-consensus`'s entrypoint.sh; configuration happens entirely through env vars, and both scripts run under `set -eu`, so an unset required variable crashes with a generic "expected X to be set" rather than a helpful error. This repo's own entrypoint.sh wrappers default what's safe to default and fail with a clearer message for what isn't (see each image's entrypoint.sh).

### Engine API JWT: shared value, not a shared file

Every Ethereum execution client in this repo generates its own JWT secret into a file on first run, guarded so a restart doesn't regenerate it (see [Ethereum Execution/Consensus Pairing](./ethereum-execution-consensus-pairing.md)) - the paired consensus client then reads that same file over a shared volume. Base works differently: neither binary generates a secret. Both `execution-entrypoint` and `consensus-entrypoint` independently write the value of `BASE_NODE_L2_ENGINE_AUTH_RAW` into their own local file at `BASE_NODE_L2_ENGINE_AUTH` on every start (`echo "$BASE_NODE_L2_ENGINE_AUTH_RAW" > "$BASE_NODE_L2_ENGINE_AUTH"`) - no shared volume is needed for the secret itself, only the same raw value passed to both containers. Generate one with `openssl rand -hex 32` and give it to both `fiftysix/base-reth` and `fiftysix/base-consensus` as `BASE_NODE_L2_ENGINE_AUTH_RAW`; this repo's entrypoints require it explicitly and refuse to start without it.

### Parent Chain (L1) Requirement

Both `fiftysix/base-consensus` env vars point at the same two things Nitro needs:

- `BASE_NODE_L1_ETH_RPC`: an execution JSON-RPC endpoint (e.g. `http://reth:8545`).
- `BASE_NODE_L1_BEACON`: a consensus client's beacon REST API that can serve blob sidecars (e.g. `http://lighthouse:5052`).

Confirmed via [Base's own docs](https://docs.base.org/base-chain/node-operators/run-a-base-node): "If running your own L1 node, it needs to be synced before Base will be able to fully sync." Since the Fusaka upgrade (PeerDAS), a default L1 consensus client cannot serve blob sidecars at all - see nodevin's `--blob-serving` flag and [Arbitrum's doc](./arbitrum.md#blob-dependency-and-backfill) for the same dependency and its backfill-timing caveat, which applies identically here.

### fiftysix/base-reth (execution)

Ports (env-var configurable, defaults shown): `RPC_PORT` 8545 (HTTP-RPC), `WS_PORT` 8546 (WS-RPC), `AUTHRPC_PORT` 8551 (Engine API), `METRICS_PORT` 6060, `DISCOVERY_PORT`/`P2P_PORT` 30303 (tcp+udp), `V5_DISCOVERY_PORT` 9200 (discv5, udp).

`RETH_DATA_DIR` is hardcoded to `/data` inside the upstream script (not overridable via env) - `VOLUME ["/data"]` accordingly, deviating from this repo's usual `/node/<client>` convention for the same reason Nitro reuses the official image's own layout instead of fighting it.

`RETH_CHAIN` selects the network: `base` (mainnet, this image's default) or `base-sepolia` (testnet) - confirmed accepted values via `--help`: `mainnet, sepolia, zeronet, dev, base, base_sepolia, base-sepolia, base-zeronet`.

`RETH_SEQUENCER_HTTP` (the endpoint transactions are forwarded to) defaults per-chain to Base's own published public sequencer endpoints (`https://mainnet-sequencer.base.org` / `https://sepolia-sequencer.base.org`) unless already set - these are not secrets.

Flashblocks (a low-latency pending-block feed) can be enabled by setting `RETH_FB_WEBSOCKET_URL`; unset by default (confirmed via entrypoint: "Running in vanilla node mode (no Flashblocks URL provided)" when absent).

### fiftysix/base-consensus (rollup/consensus)

Ports (fixed via `base-consensus node --help`, not all independently overridable by this image's entrypoint today): `9545` RPC (`BASE_NODE_RPC_PORT`), `9222` P2P (libp2p, tcp), `9223` P2P discovery (discv5, udp), `9090` Prometheus metrics.

Confirmed via `--help`: **no `--datadir`/state-directory flag exists at all**. Unlike `base-reth-node`, `base-consensus` (an OP Stack `op-node`-lineage rollup node) is a largely stateless derivation pipeline reading from L1 and the paired execution client rather than maintaining its own chain database - `VOLUME ["/data"]` here only persists the optional P2P private key (`--p2p.priv.path`) and admin-state file, so a restart keeps the same peer identity rather than announcing as a new one each time. Confirmed by omission in a real test run: without it set, a restart logs `Failed to load P2P keypair from configuration, generated ephemeral keypair`.

`BASE_NODE_NETWORK` selects the L2 chain (`base` mainnet default, `base-sepolia` testnet - matching `fiftysix/base-reth`'s `RETH_CHAIN` default so a pair agrees unless overridden).

`BASE_NODE_L2_ENGINE_RPC` must point at the paired `fiftysix/base-reth` container's authrpc endpoint (e.g. `http://base-reth:8551`), required with no default.

**Startup ordering is handled for you**: `consensus-entrypoint` polls `BASE_NODE_L2_ENGINE_RPC` in a loop until it returns HTTP 401 (meaning the execution container's authrpc server is up and correctly requiring auth) before starting - no manual wait/retry logic is needed in a compose file.

**Outbound network call on every start**: `consensus-entrypoint` fetches this machine's public IP from four external services in sequence (`ifconfig.me`, `api.ipify.org`, `ipecho.net`, `v4.ident.me`) to set `BASE_NODE_P2P_ADVERTISE_IP` for P2P discovery. This is unconditional - there's no way to disable it from this image alone (`--p2p.advertise.ip`/`BASE_NODE_P2P_ADVERTISE_IP` could be pre-set to skip it, but the entrypoint script doesn't check for that before calling out). Worth knowing before running in an environment with restricted egress.

### Snapshot Downloading

Base publishes its own snapshots at [chain.base.org/snapshots](https://chain.base.org/snapshots) (`snapshots.base.org` redirects here), updated weekly, in four sizes (mainnet, at the time of writing): Minimal (777.9 GB, state and headers only), Full (920.7 GB, adds transactions/receipts/state history), Archive (4.2 TB), Archive + Proofs (5 TB). Confirmed the download subcommand is real and present in this image:

```
base-reth-node download --chain base --archive --resumable
```

`base-reth-node download --help` confirms `--datadir` defaults to an OS-specific path (e.g. `$HOME/.local/share/reth/` on Linux), **not** `/data` - pass `--datadir /data` explicitly so the snapshot lands where `fiftysix/base-reth`'s entrypoint (and thus the running node) will actually look for it. Not yet exercised end-to-end in this repo (see Known Gaps).

### Hardware Requirements

Per [Base's own Node Performance guide](https://docs.base.org/chain/node-performance):

| Item | Requirement |
| --- | --- |
| CPU | 8+ cores, good single-core performance |
| RAM | 32 GB minimum, 64 GB recommended |
| Disk | Locally attached NVMe SSD (networked storage not recommended); capacity ≈ 2× current chain size + snapshot size + 20% buffer |
| Reference sizes | Full snapshot 920.7 GB, Archive 4.2 TB, Archive + Proofs 5 TB (mainnet, see Snapshot Downloading above) |
| Production example | Base's own production nodes run on AWS `i7i.12xlarge` with RAID 0 across all local NVMe drives |

### Flags and Configuration

For the full flag reference, run `docker run --rm --entrypoint /app/base-reth-node fiftysix/base-reth node --help` or `docker run --rm --entrypoint /app/base-consensus fiftysix/base-consensus node --help`, or see [Base's own docs](https://docs.base.org/base-chain/node-operators/run-a-base-node).

### Test Plan / Known Gaps (as of this image's first version)

A real connectivity test was run: `fiftysix/base-reth` (Base Sepolia) resolved the correct chain ID (`0x14a34` = 84532) and started its RPC/Engine API servers; `fiftysix/base-consensus`, pointed at that container's authrpc endpoint and at this repo's own already-running Sepolia L1 stack (`fiftysix/reth` + `fiftysix/lighthouse`), passed the Engine API JWT handshake (confirmed - the single "Invalid JWT" log line on the execution side was the consensus container's own unauthenticated readiness probe, not a failed real connection) and began deriving against real L1 head data.

- No real sync has been attempted. The snapshot download flow above (`base-reth-node download`) has not been exercised end-to-end, nor has a `base-consensus` derivation been run far enough to reach a synced/safe head.
- Not run on mainnet.
- Not yet wired into nodevin.
- Only `fiftysix/base-reth`'s entrypoint currently exposes port/chain env vars as documented above; `fiftysix/base-consensus`'s port/P2P-identity env vars are not yet defaulted or surfaced by this repo's entrypoint.sh beyond what's required to start.
