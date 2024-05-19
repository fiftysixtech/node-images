# Fiftysix Blockchain Node Images

## Blockchain Sync Information

### Bitcoin

| Node | Space Required | Time | Comments |
|----------|----------|----------|----------|
| Bitcoin Core | ~600MB | ~24 hours | - |
| Bitcoin Core with Ord | ... | ... | ... |

### Ethereum

...

## Installing Docker and Docker Compose

In order to run Fiftysix blockchain node images, Docker and Docker Compose is required. Below is a guide on how to install both on different operating systems.

### Ubuntu (22.04) -- Installing Docker and Docker Compose

1. **Update Your Package Index**
   ```bash
   sudo apt update
   ```

2. **Install Required Packages**
   To ensure that your APT works with HTTPS:
   ```bash
   sudo apt install apt-transport-https ca-certificates curl software-properties-common
   ```

3. **Add Docker’s Official GPG Key**
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```

5. **Add the Docker Repository**
   ```bash
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   ```

6. **Update Your Package Index** (again after adding new repository)
   ```bash
   sudo apt update
   ```

7. **Install Docker CE (Community Edition)**
   ```bash
   sudo apt install docker-ce
   ```

8. **Verify Installation**
   Verify that Docker is installed correctly by running the Hello World image.
   ```bash
   sudo docker run hello-world
   ```

9. **Manage Docker as a Non-root User** (Optional but recommended)
   If you want to run Docker commands without `sudo`, you need to add your user to the Docker group.
   ```bash
   sudo usermod -aG docker ${USER}
   su - ${USER}
   ```
   You will need to log out and back in for this to take effect.

#### Installing Docker Compose

As of Docker Compose version 1.27.0, you can use the Docker CLI plugin.

1. **Download the Latest Version of Docker Compose**
   First, check the current release and replace `<version>` with the version of Compose you want to use (for example, v2.27.0). Latest versions can be found here: [Docker Compose Releases](https://github.com/docker/compose/releases).
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/<version>/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   ```

2. **Set Permissions**
   ```bash
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Verify Installation**
   Check if Docker Compose is installed correctly:
   ```bash
   docker-compose --version
   ```

## Running a Compose File

In order to run a specific compose file, navigate to the directory and run the following command:

```
ln -s <compose-file> docker-compose.yml
```

Then run (you may need to preface this command with `sudo`):

```
docker-compose up -d
```

Logs can be tracked directly by running:

```
docker logs <container-name>
```

## Bitcoin

### Bitcoin Core

"Bitcoin Core connects to the Bitcoin peer-to-peer network to download and fully validate blocks and transactions." - [Bitcoin Core Github](https://github.com/bitcoin/bitcoin)

#### JSON-RPC

Using the base compose file, one can interact with Bitcoin Core using the following request:

```
curl --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getblockcount", "params": []}' -H 'content-type: text/plain;' http://127.0.0.1:8332/
```

More documentation can be found on the official [Bitcoin Core Github](https://github.com/bitcoin/bitcoin/blob/master/doc/JSON-RPC-interface.md).

Further information can be found on the official [Bitcoin website](http://bitcoin.org/).

### ord

`ord` is the software for Ordinals, "...an open-source project, developed on GitHub. The project consists of a BIP describing the ordinal scheme, an index that communicates with a Bitcoin Core node to track the location of all satoshis, a wallet that allows making ordinal-aware transactions, a block explorer for interactive exploration of the blockchain, functionality for inscribing satoshis with digital artifacts, and this manual." - [Ordinals Documentation](https://docs.ordinals.com/overview.html)

#### Server

Using the base compose file, `ord` will open a local web server on `http://localhost:80`. Once fully synced, you can view latest inscriptions here and make requests to the JSON-API below.

#### JSON-API

Using the base compose file, one can interact with `ord` using the following request:

```
curl -s -H "Accept: application/json" 'http://0.0.0.0:80/inscriptions'
```

More documentation can be found on the official [Ordinals website](https://docs.ordinals.com/guides/explorer.html#json-api).

## Litecoin

### Litecoin Core

"Litecoin is an experimental digital currency that enables instant payments to anyone, anywhere in the world. Litecoin uses peer-to-peer technology to operate with no central authority: managing transactions and issuing money are carried out collectively by the network. Litecoin Core is the name of open source software which enables the use of this currency." - [Litecoin Core Github](https://github.com/litecoin-project/litecoin)

#### JSON-RPC

Using the base compose file, one can interact with Litecoin Core using the following request (note the required user/pass, as specified in the Litecoin compose files):

```
curl --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getblockcount", "params": []}' -H 'content-type: text/plain;' http://user:pass@127.0.0.1:9332/
```

More documentation can be found on the official [Litecoin Core Github](https://github.com/litecoin-project/litecoin).

Further information can be found on the official [Litecoin website](https://litecoin.org/).

### ord-litecoin

`ord` is the software for Ordinals, just like Bitcoin, except on Litecoin. `ord-litecoin` is forked from the official `ord` repository, and can be found [here](https://github.com/ynohtna92/ord-litecoin).

"...an open-source project, developed on GitHub. The project consists of a BIP describing the ordinal scheme, an index that communicates with a Bitcoin Core node to track the location of all satoshis, a wallet that allows making ordinal-aware transactions, a block explorer for interactive exploration of the blockchain, functionality for inscribing satoshis with digital artifacts, and this manual." - [Ordinals Documentation](https://docs.ordinals.com/overview.html)

#### Server

Using the base compose file, `ord` will open a local web server on `http://localhost:80`. Once fully synced, you can view latest inscriptions here and make requests to the JSON-API below.

#### JSON-API

Using the base compose file, one can interact with `ord` using the following request:

```
curl -s -H "Accept: application/json" 'http://0.0.0.0:80/inscriptions'
```

More documentation can be found on the official [Ordinals website](https://docs.ordinals.com/guides/explorer.html#json-api), or on the official [ord-litecoin Github repository](https://github.com/ynohtna92/ord-litecoin).

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

