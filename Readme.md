# Solidity 

Some smart contract that can be deployed to Ethereum

Solidity is a contract-oriented, high-level language whose syntax is similar to that of JavaScript and it is designed to target the Ethereum Virtual Machine (EVM).

Solidity is statically typed, supports inheritance, libraries and complex user-defined types among other features.

Some of these examples are modified example from https://solidity.readthedocs.io




## Notes
It is a good guideline to structure functions that interact with other contracts (i.e. they call functions or send Ether)
into three phases:

1. checking conditions
2. performing actions (potentially changing conditions)
3. interacting with other contracts

If these phases are mixed up, the other contract could call back into the current contract and modify the state or cause
effects (ether payout) to be performed multiple times. If functions called internally include interaction with external
contracts, they also have to be considered interaction with external contracts.