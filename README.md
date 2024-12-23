# [nlp](https://github.com/z0r0z/zenplate)  [![License: AGPL-3.0-only](https://img.shields.io/badge/License-AGPL-black.svg)](https://opensource.org/license/agpl-v3/) [![solidity](https://img.shields.io/badge/solidity-%5E0.8.28-black)](https://docs.soliditylang.org/en/v0.8.28/) [![Foundry](https://img.shields.io/badge/Built%20with-Foundry-000000.svg)](https://getfoundry.sh/)

nani liquidity provisioning mechanisms to economically program disindividuation through personalized incentives

## deployments (ethereum & base)

### nlpz (nanilpzap.eth | nanilpzap.base.eth): *LP*
> nani lp zap (nanilpzap.eth | nanilpzap.base.eth)
[0x0000000000610170918fE0D185251953deC90526](https://etherscan.io/address/0x0000000000610170918fE0D185251953deC90526)
> > initialize liquidity with nani tokens sold for current pool price

Users can contribute ETH to receive the market equivalent in NANI and become LPs using a gas-efficient contract.

They can select between `contribute()` which selects a +-10% range at current price, or `contributeFullRange()`.

Timelock is initially set for 3 weeks under DAO admin. This can be adjusted. Additional incentives are available.

### nsfw (naniswap.eth | naniswap.base.eth): *SWAP*
> nani swap feeless win
[0x00000000003390f89025aE80E376116eBFA0Cf6b](https://etherscan.io/address/0x00000000003390f89025aE80E376116eBFA0Cf6b)
> > swap for nani at the current pool price without uniswap frontend fee- nice

## phase 0 (2666664, 0.2666664%)
> validation of nlp mechanisms
>> for security purposes, low

>> ## phase 1 (222222, 0.0222222000222222%)
> continuation of nlp mechanisms
>> for security purposes, vlow

## Getting Started

Run: `curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup`

Build the foundry project with `forge build`. Run tests with `forge test`. Measure gas with `forge snapshot`. Format with `forge fmt`.

## Disclaimer

*These smart contracts and testing suite are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of anything provided herein or through related user interfaces. This repository and related code have not been audited and as such there can be no assurance anything will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk.*

## License

See [LICENSE](./LICENSE) for more details.
