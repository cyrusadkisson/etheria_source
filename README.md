# etheria_source

Source code for Etheria and the contracts around it, with each contract's mainnet address and the
evidence that the source here matches the code on the chain.

Etheria is a virtual world deployed to Ethereum in October 2015. Its map is a 33×33 grid of 1,089
tiles that players own, trade and build on. Website: [etheria.world](https://etheria.world).

## Etheria

| Version | Address | Deployed (UTC) | Source | Source match |
|---|---|---|---|---|
| v0.9 | `0xe468d26721b703d224d05563cb64746a7a40e1f4` | block 407810, 2015-10-19 14:54 | [`etheria-0pt9_0xe46.sol`](etheria-0pt9_0xe46.sol) | Exact (solc 0.1.6) |
| v1.0 | `0xe414716f017b5c1457bf98e985bccb135dff81f2` | block 420373, 2015-10-22 03:34 | [`etheria-1pt0_0xe41.sol`](etheria-1pt0_0xe41.sol) | Near-exact; functionally the same (see the file) |
| v1.1 | `0x169332ae7d143e4b5c6baedb2fef77bfbddb4011` | block 459708, 2015-10-29 21:11 | [`etheria-1pt1_0x169.sol`](etheria-1pt1_0x169.sol) | Exact (solc 0.1.6) |
| v1.2 | `0xb21f8684f23dbb1008508b4de91a0aaedebdb7e4` | block 470957, 2015-11-01 01:20 | [`etheria-1pt2_0xb21.sol`](etheria-1pt2_0xb21.sol) | Verified on Etherscan (Nov 2021); local compiles differ only in optimizer choices (see the file) |

Each file starts with a comment giving the address, the function signatures, the ABI and notes on the
match, followed by the source.

- **v0.9 and v1.0** change tile owners only through offers (`makeOffer`, `acceptOffer` and related
  functions). Their tiles can be wrapped as ERC-721 tokens (see Wrappers below).
- **v1.1 and v1.2** have `setOwner` for direct transfers. It checks `tx.origin`, so tiles can only be
  owned by ordinary accounts: **sending a tile to a contract address loses it.**
- v0.9 has no `kill` function. v1.0, v1.1 and v1.2 have one, but each is locked, so it can never run.

**Compiling these.** solc 0.1.6 exists only as a `soljson` build in
[ethereum/solc-bin](https://github.com/ethereum/solc-bin). Its output can depend on what the same
compiler instance compiled before, so the v0.9 and v1.1 files only match after being compiled more than
once in one instance, as their headers note. [`NKNVELSC/README.md`](NKNVELSC/README.md#how-to-verify)
has a short script for driving these old compilers.

## Helper contracts

| Contract | Address | Used by | Source |
|---|---|---|---|
| BlockDefinitionStorage | `0x782bdf7015b71b64f6750796dd087fde32fd6fdc` | v0.9, v1.0 | [`_BlockDefinitionStorage_0x782.sol`](_BlockDefinitionStorage_0x782.sol) |
| BlockDefinitionStorage | `0xd4e686a1fbf1bfe058510f07cd3936d3d5a70589` | v1.1, v1.2 | [`_BlockDefinitionStorage_0xd4e.sol`](_BlockDefinitionStorage_0xd4e.sol) |
| MapElevationStorage | `0x68549d7dbb7a956f955ec1263f55494f05972a6b` | v0.9 to v1.2 | [`_MapElevationStorage_0x685.sol`](_MapElevationStorage_0x685.sol) |

BlockDefinitionStorage holds the brick shapes used by the original build mechanics. MapElevationStorage
holds each tile's elevation, which decides land and water. All three are locked, so their data can no
longer change.

## Wrappers (v0.9 and v1.0)

| Wrapper | Address | Source |
|---|---|---|
| EtheriaWrapper for v0.9 | `0x4b1705c75fde41e35e454ddd14e5d0a0eac06280` | [`EtheriaWrapper-v0pt9_0x4b1.sol`](EtheriaWrapper-v0pt9_0x4b1.sol) |
| EtheriaWrapper for v1.0 | `0x629a493a94b611138d4bee231f94f5c08ab6570a` | [`EtheriaWrapper-v1pt0_0x629.sol`](EtheriaWrapper-v1pt0_0x629.sol) |

These turn v0.9 and v1.0 tiles into standard ERC-721 tokens, using the tiles' own offer functions. Both
are Solidity 0.8.7 and verified on Etherscan. The files explain how to wrap and unwrap.

## Exchanges (v1.1 and v1.2)

| Exchange | Address | Trades | Source |
|---|---|---|---|
| EtheriaExchangeXL v1.1 | `0x341db17810769e7470b22d75127c37eec44f8179` | v1.1 tiles | [`EtheriaExchangeXL-1pt1_0x341.sol`](EtheriaExchangeXL-1pt1_0x341.sol) |
| EtheriaExchangeXL v1.2 | `0x111b76dbbe885d05793de91254554f0a781d15db` | v1.2 tiles | [`EtheriaExchangeXL-1pt2_0x111.sol`](EtheriaExchangeXL-1pt2_0x111.sol) |

Marketplaces for asks and bids, including bids for any tile within a range of columns, rows and
elevations. Both are Solidity 0.8 with verified source on block explorers.

## Test contracts from before v0.9: [`NKNVELSC/`](NKNVELSC/)

Four test versions (v0.6, v0.7, v0.8 and v0.85) deployed in September and October 2015 are still on the
chain. Each has a fatal bug, so none of them is a usable Etheria, and **anything offering their tiles is
a scam.** [`NKNVELSC/README.md`](NKNVELSC/README.md) explains each one and links to an
[exhaustive search](NKNVELSC/EXHAUSTIVE_PRE_V0pt9_SEARCH.md) showing they are the only Etheria-like
contracts from before v0.9 that still exist.

## Old build mechanics: `etheria_web_v0pt9/`, `etheria_web_v1pt0/`, `etheria_web_v1pt1/`

Etheria's original build mechanics had players farm bricks, then color and stack them, with every
placement checked for gravity, collisions and tile boundaries. That proved too expensive in gas, so in
2021 it was replaced: each tile's build is now a compressed voxel image stored in the tile's name field,
and that is what etheria.world renders.

These three folders are standalone copies of the original website that render tiles with the old
mechanics, so anyone can see how the old builds looked without taking anyone's word for it. The v1.1
folder also covers v1.2. Each folder's `_README.txt` has the details.
