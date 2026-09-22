# Ethereum Execution/Consensus Pairing: Setup Notes & Known Edge Cases

This document is the operational companion to [`docs/ethereum.md`](./ethereum.md). That file documents each client
individually (ports, flags, hardware requirements); this one documents the things that only show up when you actually
**build a new client image** or **pair an execution client with a consensus client** — found by doing both, for real,
for every client currently in this repo. Nothing here is theoretical; every claim was verified by building the image
and running it against a real paired counterpart.

If you're adding a new Ethereum client image to this repo, read this first. If you're consuming these images (e.g.
from `nodevin`, or your own compose file) to run a paired execution+consensus setup, read the "Pairing" section first.

## Why this document exists

Post-Merge Ethereum requires two node processes talking to each other over the Engine API: an execution client and a
consensus (beacon) client. They authenticate to each other with a shared JWT secret. Every consensus client image in
this repo (Lighthouse, Prysm, Teku, Nimbus, Lodestar) was built against a real execution client (`fiftysix/reth`) on a
shared Docker network, with the execution client's data volume mounted read-only into the consensus container, to
prove the pairing actually works — not just that each image runs in isolation. The lessons from doing that six times
are below.

## Pairing an execution client with a consensus client

### The JWT secret

- Every execution client image (`geth`, `besu`, `nethermind`, `erigon`, `reth`) generates `jwt.hex` on first launch
  **only if it doesn't already exist**, at `${ROOT_DIR}/data/jwt.hex` — i.e. `/node/<client>/data/jwt.hex` inside the
  container. This path is uniform across every execution client in this repo. Restarting the container does not
  regenerate (and therefore does not invalidate) the secret.
- A consensus client image must **never** generate its own `jwt.hex`. It has to use the exact same secret the
  execution client generated. None of the consensus client entrypoints in this repo do — that's deliberate, not an
  oversight.
- The way to share it: mount the execution client's data volume (or just the `jwt.hex` file) **read-only** into the
  consensus client's container, at some path under the consensus client's own `ROOT_DIR`, and point that client's
  JWT-secret flag at it.
- Real, working example (this is exactly how every consensus client in this repo was tested):
  ```bash
  docker network create eth-test-net
  docker volume create reth-data

  docker run -d --name reth-node --network eth-test-net \
    -v reth-data:/node/reth/data \
    fiftysix/reth:2.6.0

  docker run -d --name lighthouse-node --network eth-test-net \
    -v lighthouse-data:/node/lighthouse/data \
    -v reth-data:/node/lighthouse/exec-jwt:ro \
    fiftysix/lighthouse:8.2.2 bn \
      --execution-endpoint http://reth-node:8551 \
      --execution-jwt /node/lighthouse/exec-jwt/jwt.hex
  ```
  The execution client's container name (`reth-node`) is used directly as the hostname — this only works because
  both containers are on the same Docker network. This is also exactly the pattern `nodevin`'s compose generation
  will need to replicate (see the scoping notes referenced at the bottom of this doc).

### The `chown -R` trap

The very first version of the Lighthouse entrypoint did `chown -R nodeuser "${ROOT_DIR}"`. The moment a real pairing
test mounted the execution client's data **read-only** under `${ROOT_DIR}` (e.g. at `${ROOT_DIR}/exec-jwt`), that
`chown -R` failed on the read-only mount — and because the entrypoint runs under `set -e`, the whole container died
before the consensus client even started. Every consensus client entrypoint in this repo now only `chown`s its own
`${DATA_DIR}` (the writable subdirectory it actually owns), never the whole `ROOT_DIR`. **If you add a new consensus
client image, do this from the start** — the bug is invisible until someone actually tries a real pairing, exactly
the scenario this whole document exists to make routine instead of surprising.

### Does the consensus client require a paired execution client to start?

This varies by client — know which behavior you're dealing with before assuming a missing/misconfigured pairing will
fail loudly:

| Client | Behavior with no `--execution-endpoint`/equivalent |
| --- | --- |
| Lighthouse | Hard-fails immediately with a clear "required arguments were not provided" error |
| Teku | Hard-fails immediately: `--ee-endpoint parameter is mandatory when Bellatrix milestone is enabled` |
| Prysm | Starts anyway, using its own built-in default (`http://localhost:8551`), and logs a repeating non-fatal `ERROR` for the connection failure |
| Nimbus | Starts anyway with `elUrls: []`, no error, no warning |
| Lodestar | Starts anyway, using its own built-in default (`http://localhost:8551`, same as Prysm's situation) |

None of the Fiftysix entrypoints inject a fake default for these flags — there isn't a correct one, since it has to
point at whichever execution client this node is actually paired with. Where the client's own CLI already has a
default (Prysm, Lodestar), that default is left alone rather than overridden with something equally wrong.

### Genesis sync / weak subjectivity guards

Some consensus clients refuse to sync from genesis by default (a real security posture, not a bug):

| Client | Genesis sync behavior |
| --- | --- |
| Lighthouse | Refuses (`Syncing from genesis is insecure...`) unless `--allow-insecure-genesis-sync` is passed. Even then, a **second**, separate guard (weak subjectivity) still refuses unless `--ignore-ws-check` is also passed. |
| Teku | Refuses (`Cannot sync outside of weak subjectivity period`) unless `--ignore-weak-subjectivity-period-enabled=true`, or a real `--checkpoint-sync-url` is used. |
| Nimbus | No hard block — proceeds and warns. |
| Prysm | No hard block observed. |
| Lodestar | Warns (`Initializing from a stale checkpoint state vulnerable to long range attacks`) and proceeds. |

None of the images bake in a default third-party checkpoint-sync endpoint — that's an explicit choice (an image
shouldn't silently pick who you trust for checkpoint data). For real deployments, pass `--checkpoint-sync-url`
yourself. The `--allow-insecure-genesis-sync`/`--ignore-ws-check`/`--ignore-weak-subjectivity-period-enabled` flags
above exist for local testing only — the pairing tests in this repo's PRs used them for exactly that reason, spelled
out in each PR description rather than left unstated.

### Default ports, at a glance

| Client | REST/Beacon API | P2P |
| --- | --- | --- |
| Lighthouse | 5052 | 9000 (TCP/UDP) |
| Prysm | 3500 | TCP 13000 / UDP 12000 |
| Teku | 5051 | 9000 (TCP/UDP) |
| Nimbus | 5052 | TCP/UDP 9000, QUIC UDP 9001 |
| Lodestar | 9596 | 9000 (TCP/UDP) |

## `node-base` version selection

- `0.1.x` → `0.2.0`: added ARM64 support. Purely additive — nothing already on `0.1.2` was migrated.
- `0.2.0` → `0.3.0`: added `ubuntu:24.04` (glibc 2.39) instead of `ubuntu:22.04`. Required for **Reth** and
  **Lodestar** specifically — both fail outright on `0.2.0` (`GLIBC_2.39 not found` / `GLIBCXX_3.4.31 not found`).
  Also purely additive.
- Building `0.3.0` surfaced two real Ubuntu-24.04-specific breakages that a naive "just bump `FROM ubuntu:22.04` to
  `ubuntu:24.04`" would not have caught without actually building and running it:
  - The `ntp` package is a transitional package that installs `ntpsec`; its init script is registered as `ntpsec`,
    not `ntp`.
  - `ubuntu:24.04`'s own image ships a pre-existing `ubuntu` user/group at UID/GID 1000, colliding with this repo's
    `nodeuser`/`nodegroup` convention. Removed via `userdel -r ubuntu` before creating `nodeuser`.
- **Default going forward:** new client images should build on `0.3.0` even if the client doesn't strictly need
  glibc 2.39 (Lighthouse, Prysm, Teku, and Nimbus don't — they were moved/built on `0.3.0` anyway, purely to avoid
  fragmenting the fleet across two otherwise-equivalent bases for no reason). This is **not** a recommendation to
  retroactively migrate `geth`/`besu`/`nethermind`/`erigon` off `0.1.2`/`0.2.0` — there's no functional need, and doing
  so would mean re-verifying every one of those images for no benefit. It's about what new images should start from.

## Binary verification: what's actually available per client

Not every upstream project publishes the same authenticity guarantees. Match the verification step to what's
actually available — don't fake a stronger guarantee than exists, and don't skip a real one that does exist:

| Client | What's published | What this repo does |
| --- | --- | --- |
| Erigon | Unsigned `checksums.txt` | Fetch + `sha256sum -c` at build time |
| Teku | Unsigned `.sha256` per asset | Same as Erigon |
| Reth, Lighthouse, Prysm | Detached GPG signature per asset (Prysm also has an unsigned `.sha256`, but that adds nothing beyond the signature) | `gpg --verify` against a pinned, confirmed maintainer fingerprint |
| Nimbus | `.sha512sum` bundled **inside** the release tarball, next to the binary it describes | Verified against it, but documented as weak: both the binary and its checksum come from the same artifact, so it catches transfer corruption only, not a tampered release |
| Besu, Nethermind, Lodestar | Nothing at all | No verification step (same posture as Besu/Nethermind, which predate this round of work) |

For a GPG-verified client: fetch the signature key from `keyserver.ubuntu.com`, pin the **full fingerprint** (never a
short key ID) as a Dockerfile `ENV`, and confirm the "aka" identities in the `gpg --verify` output actually match the
project before trusting it — this is how the Reth/Lighthouse/Prysm keys were each confirmed as the real
Paradigm/Sigma Prime/Prysmatic Labs maintainer, not just "a key that happens to verify."

## CLI parsing edge cases, per client

Every client's flag-parsing library behaves differently on things this repo's entrypoints depend on: whether a
duplicated flag errors, silently takes the last value, or silently does something wrong. **Never assume one client's
behavior generalizes to the next — verify it for the specific client, and re-verify for a specific flag shape if the
client has more than one (see Lodestar below).**

| Client | CLI library | Duplicate flag behavior | Entrypoint pattern used |
| --- | --- | --- | --- |
| Reth | clap | Errors: `cannot be used multiple times` | `has_flag` conditional default |
| Lighthouse | clap | Same as Reth | `has_flag` conditional default |
| Teku | picocli | Errors: `should be specified only once` | `has_flag` conditional default |
| Prysm | urfave/cli | Silently takes the last value | Simple prepend (defaults first, caller args after) |
| Nimbus | confutils (Nim) | Silently takes the last value | Simple prepend |
| Lodestar | yargs | **Inconsistent within the same CLI** — see below | `has_flag` conditional default |

**Lodestar's yargs quirk is the sharpest edge case found in this whole effort.** A duplicated top-level scalar flag
(confirmed with a non-dotted option) takes the last value, same as Prysm/Nimbus. But a duplicated **dotted** flag —
e.g. `--rest.port 9596 --rest.port 9999` — gets coerced by yargs into an **array** (`port: [9596, 9999]`) instead of
either single value, and the REST server then crashes with `The argument 'options' is invalid`. This was caught only
because the override path was actually tested with a real flag override, after an earlier duplicate-flag check
(using a *different* flag) had already been assumed to generalize. **The lesson: verify duplicate-flag handling with
the actual flag shape you're going to use in the entrypoint (dotted vs. flat), not just any flag.** Given this, every
consensus client entrypoint in this repo uses the `has_flag`-conditional-default pattern uniformly — it's the only
approach that's safe regardless of which of the above behaviors the underlying CLI turns out to have, and it doesn't
cost anything to use even where "simple prepend" would also have worked (Prysm, Nimbus).

**Required flag syntax also isn't uniform.** Nimbus's (confutils) CLI only accepts `--flag=value` — a space-separated
`--flag value` is silently misparsed as two separate tokens and fails with a confusing `does not accept arguments`
error. Every other client in this repo accepts both `--flag value` and `--flag=value` interchangeably.

**Some clients require a flag just to run non-interactively in a container at all:**
- Prysm requires `--accept-terms-of-use`, or it blocks on stdin waiting for an interactive accept/decline prompt and
  fails fast (not hang forever) once it detects no TTY.
- Nimbus's own docs describe `--non-interactive` as "quit on missing configuration" — not confirmed to be strictly
  required to avoid a hang the way Prysm's flag is, but the Fiftysix entrypoint always passes it anyway, since a
  container should never be waiting on a TTY prompt under any circumstance.

## Environment-variable name collisions (the single most surprising class of bug found)

Two, unrelated, completely different mechanisms — same symptom: an env var this repo's own Dockerfile set, silently
changing the running client's behavior with no error pointing at the actual cause.

- **Teku**: naming the Dockerfile's build-time version variable `TEKU_VERSION` (matching this repo's usual
  `ERIGON_VERSION`/`RETH_VERSION`-style convention) collides with an **undocumented env var Teku's own Java code
  reads internally**. Setting it silently short-circuits the app into printing its version banner and exiting
  immediately, no matter what CLI flags are passed — no error, no hang, just a container that looks like it's
  "working" and never actually runs a beacon node. Fixed by renaming to `TEKU_CLIENT_VERSION`.
- **Lodestar**: naming the Dockerfile's build-time version variable `LODESTAR_CLIENT_VERSION` (the very convention
  adopted specifically to *dodge* Teku's collision above) hits a **different** mechanism: Lodestar's CLI (yargs) does
  prefix-based environment variable auto-mapping — any `LODESTAR_*` env var is treated as an implicit CLI flag
  override. `LODESTAR_CLIENT_VERSION` maps to a nonexistent `--clientVersion` flag and hard-fails every invocation
  with `Unknown argument: clientVersion`. Fixed by renaming to just `CLIENT_VERSION` (dropping the client-name prefix
  entirely for this one Dockerfile).
- **Besu's Dockerfile already avoided this**, using `BESU_CLIENT_VERSION` instead of `BESU_VERSION` — possibly for
  exactly this reason, before this round of work ever started.

**When adding a new Java or Node-based client image, check for this class of bug specifically** — it doesn't show up
as a build failure, and the container will look superficially fine (it starts, it exits 0, `docker logs` shows
something) right up until you notice it never actually did anything. The way both of the above were actually caught:
noticing the container's log output looked exactly like a `--version` invocation instead of a real startup sequence,
then confirming by unsetting the suspect env var and re-running.

## Self-extracting bundles (Lodestar-specific, but a pattern worth knowing)

Lodestar's release binary is a [caxa](https://github.com/leafac/caxa)-packaged self-extracting bundle: a full Node.js
runtime plus the app, unpacked into `/tmp/caxa` on first run (~130MB, several seconds). Since that target is a plain
directory, it persists once written into a Docker image layer — so the Fiftysix Dockerfile runs the binary's
`--version` once at build time purely to trigger that extraction, baking the already-unpacked cache into the image.
Confirmed effect: the "Unpacking Lodestar binary, please wait..." message never appears again on a fresh container
start. This does **not** make startup instant — Node.js still takes a few seconds to boot an app this large regardless
— it just avoids re-paying the unpack cost on every single container start/restart. If a future client ships this way
too, the same one-line fix applies: run the binary once, for any no-op command, during the image build.

## Verification discipline this whole effort followed

Every claim in this document, and every client image in this repo, was checked against the real thing, not assumed:

- Every binary was actually downloaded and run inside the target base image before being declared compatible.
- Every GPG signature was actually verified (`gpg --verify`), not just assumed present because a `.asc` file existed.
- Every consensus client was actually paired against a real running execution client (`fiftysix/reth`) over a shared
  Docker network with a shared JWT volume, and the pairing's success was confirmed via the consensus client's own
  logs or REST API (e.g. `el_offline: false`, real `head_slot` progress, an explicit `Execution Client version: Reth
  2.6.0` log line) — never assumed to work just because both images built and started without crashing.
- Every entrypoint's flag-override path was tested with an actual overriding flag, not just the default path. (This
  is specifically what caught Lodestar's array-coercion bug — the default path alone would never have surfaced it.)

## Related: `nodevin`'s consumption of these images

`nodevin` (the sibling orchestration CLI) is the primary consumer of these images and needs to replicate the exact
pairing mechanics documented above — the JWT volume-mount pattern, the per-client flag names for the execution
endpoint and JWT secret path, and the container-hostname-based engine endpoint URL. That work is scoped separately in
`nodevin`'s own repo; this document is the reference for what that scoping work has to account for.
