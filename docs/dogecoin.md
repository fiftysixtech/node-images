## Dogecoin

### Dogecoin Core

"Dogecoin is a community-driven cryptocurrency that was inspired by a Shiba Inu meme. The Dogecoin Core software allows anyone to operate a node in the Dogecoin blockchain networks and uses the Scrypt hashing method for Proof of Work. It is adapted from Bitcoin Core and other cryptocurrencies." - [Dogecoin Github](https://github.com/dogecoin/dogecoin)

#### JSON-RPC

Using the base compose file, one can interact with Dogecoin Core using the following request (note the required user/pass, as specified in the Dogecoin compose files):

```
curl --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getblockcount", "params": []}' -H 'content-type: text/plain;' http://user:pass@127.0.0.1:22555/
```

More documentation can be found on the official [Dogecoin Core Github](https://github.com/dogecoin/dogecoin).

Further information can be found on the official [Dogecoin website](https://dogecoin.com/).
