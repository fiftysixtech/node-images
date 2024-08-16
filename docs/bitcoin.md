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
