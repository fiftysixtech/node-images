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
