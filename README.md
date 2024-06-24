## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.


## Documentation

https://book.getfoundry.sh/


## Usage


### Build

```shell
$ forge build
```


### Test

```shell
$ forge test
```


### Format

```shell
$ forge fmt
```


### Gas Snapshots

```shell
$ forge snapshot
```


### Anvil

```shell
$ anvil
```


### Deploy

```shell
$ forge script script/Bridge.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```


**Please take note of the CONTRACT ADDRESSES once you deploy this to the blockchain. You will need this address later.**


### Cast

```shell
$ cast <subcommand>
```


### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


### Contract Functions ###

Run this command in your terminal to get the list of functions in the contract along with the data types and arguments you must pass.

```
cat out/Bridge.sol/Bridge.json | jq -r '.abi | map(select(.type == "function")) | .[] | "\(.name)(\(.inputs | map(.type + " " + .name) | join(", ")))"'
```

If done correctly, you should see the following:

```
- completeTransfer(address token, uint256 amount, string sourceChain, address to)
- initiateTransfer(address token, uint256 amount, string destinationChain, address to)
- lockedFunds(address , string )
- owner()
```


Run the owner() function to get the contract owner's wallet address. This is a **READ** function and consumes no gas.

```
cast call <bridge_contract_address> "owner()(address)" --rpc-url <your_rpc_url>
```

Run the initiateTransfer() function to begin the cross chain transaction. This is a **WRITE** function that modifies or changes the state of the blockchain, so make sure you have a sufficient amount for gas fees.

```
cast send <source_bridge_contract_address> "initiateTransfer(address,uint256,string,address)" <source_token_address> <amount> <destination_chain> <recipient_address> --rpc-url <your_rpc_url>
```

**NOTE:** <destination_chain> must be specified as a STRING (ex: "sepolia")


Run the completeTransfer() function to finalize the cross chain transaction. This is a **WRITE** function that modifies or changes the state of the blockchain, so make sure you have a sufficient amount for gas fees.

```
cast send <contract_address> "completeTransfer(address,uint256,string,address)" <token_address> <amount> <source_chain> <recipient_address> --rpc-url <your_rpc_url>
```

**NOTE:** <source_chain> must be specified as a STRING (ex: "amoy")


# Bridge

The Bridge contract allows users to move tokens cross chain.  For example, if you have Wrapped MATIC on the Polygon network, you can move those tokens to Wrapped MATIC on the Ethereum network.

This contract was successfully tested and deployed on the [Sepolia](https://sepolia.etherscan.io/address/0xEa50fE7583F5e758d01A74bDDCa0a98dd77a1c98) testnet and the [Polygon Amoy](https://amoy.polygonscan.com/address/0x9AfBc22eb8F3101d9D9968D89644380FDCaF3565) testnet.

**NOTE:** It is imperative that you deploy this contract on both the SOURCE and DESTINATION blockchains. Here's why:

```
1. The bridge contract on the source chain locks or burns the specified amount of tokens.
2. An event is emitted by the source chain bridge contract with the transfer details.
3. A relayer or oracle listens for this event and sends a message to the bridge contract on the destination chain, providing proof of the lock/burn on the source chain.
4. The bridge contract on the destination chain verifies the proof and mints or unlocks the equivalent amount of tokens on the destination chain to the specified recipient address.
```




