# ReproduceDeFiHack-xCarnival

[Video Tutorial](https://youtu.be/Nh768zub23I)

# About the attack
1. [News](https://twitter.com/peckshield/status/1541047171453034501)
2. [Attack txs](https://etherscan.io/txs?a=0xb7cbb4d43f1e08327a90b32a8417688c9d0b800a)

# Requirement
1. Mainnet forking: Create an account on [moralis](https://moralis.io/)
2. [Foundry](https://github.com/foundry-rs/foundry)

# Usage
```
forge test --contracts ./test/Contract.t.sol --fork-url https://speedy-nodes-nyc.moralis.io/[API KEY]/eth/mainnet/archive --fork-block-number 15028846 -vv
```
