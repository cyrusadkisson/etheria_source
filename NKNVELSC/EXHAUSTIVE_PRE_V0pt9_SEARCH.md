# Exhaustive search for Etheria-like contracts deployed before v0.9

Etheria v0.9 (`0xe468d26721b703d224d05563cb64746a7a40e1f4`) was deployed on 2015-10-19, as the first
transaction in block 407,810. This document checks every contract deployed on Ethereum mainnet before
that point, blocks 0 through 407,809, for anything Etheria-like.

## Result

- Only one account deployed Etheria-like contracts before v0.9: the creator's presale account,
  `0xcf684dfb8304729355b58315e8019b1aa2ad1bac`. It deployed 104 of them, from 2015-09-26 to 2015-10-19.
- Four of those 104 exist today: v0.6, v0.7, v0.8 and v0.85. They are the four contracts in this
  folder, and each has a fatal bug described in its file.
- The other 100 no longer exist. 87 self-destructed, and 13 never had any code (failed deployments,
  or contracts that self-destructed in the same block). A contract that no longer exists cannot be
  restored: its address came from the deployer's address and transaction number, and that number
  can never be used again.
- No other account deployed any contract with an Etheria function, or with compiled code that
  resembles an Etheria contract.

"Etheria-like" here means a contract with at least one function for owning or trading tiles:
`getOwners`, `getOwner`, `setOwner`, `makeOffer`, `acceptOffer`, `buyTile` or `initializeOwners`.
Contracts from other accounts were also held to two broader tests, described in part 2.

## Part 1: the creator's accounts

The creator listed 42 accounts associated with him. Eleven of them existed in 2015, meaning they had
a balance or had sent a transaction by the last block of 2015 (block 778,482). The other 31 had
neither, so they cannot have deployed anything before v0.9.

| Account | Transactions sent before v0.9 | Contracts deployed before v0.9 |
|---|---:|---:|
| `0xcf684dfb8304729355b58315e8019b1aa2ad1bac` (presale) | 1,397 | 333 |
| `0x916e7b1ff5134e5544c6b127b0a5240d3a9c45d1` | 166 | 0 |
| `0xb324459dacd18d463f20ba4fa7e10432f59d4043` | 6 | 0 |
| `0xacc71c3960c3853213da618d071bba0c11cc50dd` | 5 | 0 |
| `0x910561dc5921131ee5de1e9748976a4b9c8c1e80` | 1 | 0 |
| `0x8f5fc1b505d77a04bd2608fff9884ac3ebd87f20` | 0 | 0 |
| `0x0a04205345a4c278e223e1c3f9b20afbaf6a32a0` | 0 | 0 |
| `0x2d59ac06b1eb55990703fea82fb660c4866c612e` | 0 | 0 |
| `0x8de2ce41308b824c346a87f8c8d8a60cab739473` | 0 | 0 |
| `0xe37c9ece5d14e95dd60fa3b7785142a6768c54f4` | 0 | 0 |
| `0xf520f4813b5438c690eef9678d2ca971e87f0af4` | 0 | 0 |

Deploying a contract takes a transaction, so the six accounts with none deployed nothing.

**Every transaction.** Ethereum numbers each account's transactions 0, 1, 2 and so on, so an
account's transaction count at block 407,809 is exactly how many it sent before v0.9. All 1,575
transactions were found, and each account's numbers were checked to run from 0 with no gaps.

**Every deployment.** 333 of those transactions deployed a contract, all of them from the presale
account, from 2015-08-26 to 2015-10-19. A contract's address follows from the deployer's address and
the transaction's number, so each address was computed and its code read as of the end of the block
it was deployed in. That catches contracts that later self-destructed.

| Kind | Deployed | Exist today | Self-destructed | Never had code |
|---|---:|---:|---:|---:|
| Etheria-like | 104 | 4 | 87 | 13 |
| Helpers for Etheria (block definitions, map elevations, coordinate checks) | 41 | 14 | 24 | 3 |
| Other tests (greeter, ping-pong, coin flip, call-detail probes and similar) | 188 | 7 | 166 | 15 |

All 87 self-destructed Etheria-like contracts contain a self-destruct instruction.

Contracts can also create contracts. The creator's contracts created four: three 259-byte contracts
whose only function is `getDescription`, all self-destructed, and one 208-byte contract with no
functions, which still exists (listed below).

**Before v0.6.** 22 of the Etheria-like contracts were deployed before v0.6 (block 314,103), the
first on 2015-09-26 at 23:05 UTC. None of them exists today.

### What still exists

Besides v0.6, v0.7, v0.8 and v0.85, 22 of the creator's contracts from before v0.9 exist today.
None has a function for owning or trading tiles.

| Address | Deployed (UTC) | Size | What it is |
|---|---|---:|---|
| `0x759ad41608dded2e704cc370ede5279d24239a87` | 2015-08-26 | 155 B | No functions; never writes to storage |
| `0xad826cffab6b6721889ed8e726f402c7d6d33547` | 2015-08-31 | 1,347 B | Test that reports call and block details (`getMsgSender`, `getBlockTimestamp` and similar) |
| `0xc5edca3ebf230f0df3d75b3138d733fe58d234a0` | 2015-08-31 | 2,357 B | Test that records call details (`getMsgData`, `getMsgGas` and similar) |
| `0x2ed055ab9d4697197d4b767b2a7a0cdb93bbc124` | 2015-09-30 | 259 B | One function, `getDescription` |
| `0xadccb16c0cc9cc2c419a30f7d58466b7139f91c2` | 2015-09-30 | 208 B | No functions; one storage-write instruction |
| `0x9fb0b5c0cbbd30a9e8ce9c81c686a797121d69b8` | 2015-09-30 | 208 B | No functions; one storage-write instruction |
| `0x210fe31af3871297503f4e46c6d1be8d2366fa2d` | 2015-09-30 | 208 B | No functions; one storage-write instruction. Created by the creator's contract `0x957a1fa9deca64e4a92312f01a20b85df5929826` |
| `0xdf2ac0fe2371dc31fbbf9a75e01325a169453c32` | 2015-10-14 | 405 B | Coordinate check (`blockHexCoordsValid`) |
| `0x6e6012f66e8d0e374b1a9fd7e95c5f1dece95640` | 2015-10-14 | 393 B | Coordinate check (`blockHexCoordsValid`) |
| `0x18b84dfffa22fc3bf502cc46ac64d13306df4d41` | 2015-10-14 | 408 B | Coordinate check (`blockHexCoordsValid`) |
| `0xf20c9fa34847f6bc42b2f60014268bec65676af7` | 2015-10-14 | 522 B | Coordinate check (`blockHexCoordsValid`, `getUint8FromByte32`) |
| `0x08dbb4cccccf1cfdc4affaeac7632781e67df9fe` | 2015-10-15 | 1,699 B | Block-definition storage (`getOccupies`, `getAttachesto`, `initOccupies`) |
| `0x7594db6e1bdae4aee261dcba1fdfb21eeadcd5f1` | 2015-10-16 | 1,699 B | Block-definition storage (same functions) |
| `0xed9c3aead241f6fd8e6b6951e29c3dcb5b3662c1` | 2015-10-16 | 1,730 B | Block-definition storage (same functions) |
| `0x5bc362054afda72c6a5b42f9a36c1a1b3524dd6c` | 2015-10-16 | 762 B | Map-elevation storage (`getElevation`, `getElevations`, `initElevations`) |
| `0xc35a4e966bf792734a25ea524448ea54de385e4e` | 2015-10-16 | 762 B | Map-elevation storage, used by v0.85 |
| `0xe9bea412f95dd62d9dc0f53461e1be1d993afe23` | 2015-10-17 | 558 B | Two unnamed functions; never writes to storage |
| `0x05be2f69bfcad949c0094e8caba3369f89a34d40` | 2015-10-17 | 589 B | Two unnamed functions; never writes to storage |
| `0xc81fae1c611e5155df157f606ace3fc6be25ad3f` | 2015-10-17 | 1,234 B | Block-definition storage, with a lock (`setLocked`) |
| `0x57cdd5582a02e53e833ea4592ec8296110e5f884` | 2015-10-17 | 1,234 B | Block-definition storage, with a lock |
| `0x782bdf7015b71b64f6750796dd087fde32fd6fdc` | 2015-10-17 | 1,032 B | Block-definition storage, used by v0.85 (source: `_BlockDefinitionStorage_0x782.sol` in this repo) |
| `0x68549d7dbb7a956f955ec1263f55494f05972a6b` | 2015-10-18 | 523 B | Map-elevation storage, with a lock (source: `_MapElevationStorage_0x685.sol` in this repo) |

### All 104 Etheria-like contracts

<details>
<summary>Show the list</summary>

| # | Address | Deployed (UTC) | Block | Today |
|---:|---|---|---:|---|
| 1 | `0x214f1ead3a3a7cf85c2d39652c44efc28d167f67` | 2015-09-26 23:05 | 295461 | self-destructed |
| 2 | `0x1f525bc62ec63c8ae1bcd2885192a16f9fe8e64a` | 2015-09-27 16:03 | 298916 | self-destructed |
| 3 | `0xf736864abe4d812ba2182c202764844a28bf3c59` | 2015-09-27 16:10 | 298937 | never had code |
| 4 | `0xe373ea2df5fde83a29a38dbe1a8fd05a2015d1fb` | 2015-09-27 16:14 | 298950 | never had code |
| 5 | `0x413dcb07a46f8ab82c1eaf24ceb45a5ae44a8608` | 2015-09-27 16:19 | 298960 | self-destructed |
| 6 | `0xa93b1b5f70bad509dc2777563cf97dd7c950e53e` | 2015-09-27 17:01 | 299096 | self-destructed |
| 7 | `0xb61f8327d15af15b3cf3ba09063304af17b38643` | 2015-09-27 17:06 | 299119 | never had code |
| 8 | `0x6d6f1871ce2fa7b56c352ffacd039bd2253ddf09` | 2015-09-27 18:16 | 299376 | never had code |
| 9 | `0xeec0773a49426ddc7ba0c6e2e7bd36b4d8e50b95` | 2015-09-27 18:19 | 299383 | never had code |
| 10 | `0x80d6dd984817e60cd2a8ae6ba3c4221412432c7f` | 2015-09-27 18:33 | 299422 | never had code |
| 11 | `0x708e375919b699094df88c09cdb193c8aa59c2d2` | 2015-09-27 18:39 | 299448 | never had code |
| 12 | `0xfcdc54b317eaf4eae3dbd665704a1a69d66c8a15` | 2015-09-27 18:43 | 299460 | self-destructed |
| 13 | `0x661a6484cdd8c8cfda55966f44f6e991ff95e3f3` | 2015-09-27 18:45 | 299465 | self-destructed |
| 14 | `0xd6cb0a97eb60f2351585642dd043ba4bba7dc3c1` | 2015-09-27 19:07 | 299534 | self-destructed |
| 15 | `0xb0be528ddbc5a7fab0f44feb579c64fa7c195540` | 2015-09-27 19:20 | 299573 | self-destructed |
| 16 | `0x154e70baa941675e5f77cf25a0047f0ece426860` | 2015-09-27 19:49 | 299666 | self-destructed |
| 17 | `0xc0bab15d1aeba401316c95b02b542167fb733dde` | 2015-09-28 17:59 | 303991 | self-destructed |
| 18 | `0xb7f3db79312db4551ce64aa432aa1f32ca5f4a45` | 2015-09-28 18:22 | 304061 | self-destructed |
| 19 | `0x5be6129ce8f523753131eb11c6f719f5b72e0e11` | 2015-09-28 20:45 | 304526 | self-destructed |
| 20 | `0x4a12965ea0664f61a881bc5ac02ee19a980acf74` | 2015-09-28 21:16 | 304633 | self-destructed |
| 21 | `0x7356159f3e9c9a629d0e0ab23daa47d18bcebd22` | 2015-09-29 13:58 | 307822 | self-destructed |
| 22 | `0xbef64f2491c22e639d0c8133db04c8c8a695586a` | 2015-09-29 14:42 | 307951 | self-destructed |
| 23 | `0x6489fc370c7df314ee0bdfb1fbd185f1bc457d89` | 2015-09-30 21:37 | 314103 | **exists (v0.6)** |
| 24 | `0x915f6a8fac7e4de205b72aa30289354921cbeb90` | 2015-09-30 21:59 | 314188 | self-destructed |
| 25 | `0xb9286a788806b13aad71ae2add935d550bf7ea33` | 2015-10-01 16:28 | 318139 | self-destructed |
| 26 | `0x6c3afb0adc5ecb094a06601ceac1a90a47d4b066` | 2015-10-01 17:37 | 318403 | self-destructed |
| 27 | `0xfdf00e23dbe2240d07127b6289e59d64b7cdda76` | 2015-10-01 17:43 | 318431 | self-destructed |
| 28 | `0x55a8264a6ee08ef9878c1e395e4041df6ee28832` | 2015-10-03 16:19 | 328416 | self-destructed |
| 29 | `0x67df020d60db5fc673774ec6c0c589f7d960d58b` | 2015-10-03 17:22 | 328635 | self-destructed |
| 30 | `0x236493502bdd660940942b9a38c48ef0539e3cf2` | 2015-10-03 17:36 | 328688 | self-destructed |
| 31 | `0xb5a79525ea8302e7b489a1f55b0df6021ad1dee1` | 2015-10-03 22:52 | 329762 | self-destructed |
| 32 | `0x5177ba9bd8cbe8f95632b4e32f87a045469a2672` | 2015-10-03 23:53 | 329979 | self-destructed |
| 33 | `0x27f5d585627f1a775e4db66c3b44fc994849e99b` | 2015-10-03 23:54 | 329983 | self-destructed |
| 34 | `0x9147f75b7da0a69cc99a51054d6ebfc12356ae9d` | 2015-10-03 23:54 | 329984 | self-destructed |
| 35 | `0x0ab6bbc215ba128a30d480c3d201798fb0252d0a` | 2015-10-03 23:54 | 329985 | self-destructed |
| 36 | `0x17c1de7250c4d048c3c2e5521e9a72107ca0421e` | 2015-10-03 23:57 | 329991 | self-destructed |
| 37 | `0x7f79493141a42fd51ec9c4dc5e31af33e8e354ee` | 2015-10-04 00:16 | 330041 | self-destructed |
| 38 | `0xd930e23c857865f33ae2e44201f5630ee98dc470` | 2015-10-04 00:20 | 330051 | self-destructed |
| 39 | `0xf01b35a7c859068894b85a15133d241119d5bd03` | 2015-10-05 02:39 | 335442 | self-destructed |
| 40 | `0xd5274c05f44f51397a7eedaa12f060b101c29f3c` | 2015-10-05 12:25 | 337441 | self-destructed |
| 41 | `0x1e6a3dc8a2c9447a0e18202a28e3719f9086f262` | 2015-10-05 12:39 | 337485 | self-destructed |
| 42 | `0x7a0de4e1a3cd421cb5d1226a3c2b27b75a1fab5d` | 2015-10-05 23:36 | 339795 | self-destructed |
| 43 | `0x3cb9872c4c3d380a65646d5d892cde39f072d982` | 2015-10-06 01:06 | 340114 | self-destructed |
| 44 | `0x5ee4861cda18c9f5288391d209a2c4ecab92dfd8` | 2015-10-06 15:45 | 343073 | self-destructed |
| 45 | `0x2eeff8cbcaa04ede72e6f6a8a6ba3a77d6328db3` | 2015-10-07 13:55 | 347589 | self-destructed |
| 46 | `0x52f3371fb5cafd10ba6f5cc9ffed090ae7db7f18` | 2015-10-07 15:56 | 348011 | self-destructed |
| 47 | `0xc8a2ff5b87497d41da444aad624d30976ae02094` | 2015-10-07 16:50 | 348194 | self-destructed |
| 48 | `0x1a50d0210fd4ea852260dad53801785cc31d978a` | 2015-10-07 19:17 | 348722 | self-destructed |
| 49 | `0xa965793bda06c26546e36bbad5619bff00b801b5` | 2015-10-07 20:08 | 348901 | self-destructed |
| 50 | `0x2431812a1b0568f5b886156da95fc15fb351daaf` | 2015-10-08 01:04 | 349932 | self-destructed |
| 51 | `0xdfe06177553657933e48bf412bdadcbce660ac41` | 2015-10-08 01:41 | 350066 | self-destructed |
| 52 | `0x17edb4747f549d83638454a072b8eaee71a27583` | 2015-10-08 01:58 | 350131 | self-destructed |
| 53 | `0xbc42c84ef4a54c655c5e8bfc8bf119fef55d1543` | 2015-10-08 02:17 | 350200 | self-destructed |
| 54 | `0x06fac5d1d707b8df8afe2f2b3948191c9d50fe84` | 2015-10-12 14:59 | 372901 | never had code |
| 55 | `0x34c2b8975b47e13818f496cf80b40566798cf968` | 2015-10-12 17:22 | 373420 | never had code |
| 56 | `0x1ac9b4669f7aa4c4b2aa84a931520c23dd3b86a1` | 2015-10-12 17:39 | 373497 | self-destructed |
| 57 | `0xc31ba27585978de7df2b7cb3797b21b9531335ec` | 2015-10-13 14:36 | 377997 | self-destructed |
| 58 | `0xc467b893e29277f9b62b4ed6c9ba054bd8225bff` | 2015-10-13 19:38 | 379054 | never had code |
| 59 | `0x1312fd55346f4ced45e0da98cd5ab0dc50a5459f` | 2015-10-13 23:37 | 379920 | self-destructed |
| 60 | `0x1251d13cde439378349f039379e83c2641b6269f` | 2015-10-14 15:39 | 383214 | never had code |
| 61 | `0x12c814cebee6bb08a5d1b9d009332bf8b536d645` | 2015-10-14 17:58 | 383672 | never had code |
| 62 | `0x0148368e9efd8d6a5dd56134cd2b3f941e10d953` | 2015-10-14 18:08 | 383700 | **exists (v0.7)** |
| 63 | `0xcf1eecf5929c151427dc3662a28353266ea3f9e6` | 2015-10-15 03:55 | 385709 | **exists (v0.8)** |
| 64 | `0xc40c3fda1dfe0e51412b3a45dc43fd41ebf56998` | 2015-10-15 05:08 | 385974 | self-destructed |
| 65 | `0x80d2fe61259d58244ec154157c91100b0d644a9c` | 2015-10-15 14:59 | 387954 | self-destructed |
| 66 | `0x8dc6fcaa59794e7e815bad3c9682fbb7d4b1561e` | 2015-10-15 15:04 | 387981 | self-destructed |
| 67 | `0x166c65ebf9c4d70fe96333c882dcaffe32db1a55` | 2015-10-15 15:23 | 388050 | self-destructed |
| 68 | `0xe0bddbf9d8197d64b8ff39b47280353411012f49` | 2015-10-15 15:48 | 388136 | self-destructed |
| 69 | `0x3687cd4de264c46aa2323965e6d0d667bd2fae48` | 2015-10-15 16:03 | 388186 | self-destructed |
| 70 | `0x9d303235b4333be1a073dbefb560eafc2de72600` | 2015-10-15 18:39 | 388746 | self-destructed |
| 71 | `0xa80e44e7daabf0ea2a90591ab2ff2ebaa0ea66a4` | 2015-10-15 19:26 | 388887 | self-destructed |
| 72 | `0x4c41e5cf5ce59a8f3e090b4b08e108bbbae7250b` | 2015-10-15 19:30 | 388898 | self-destructed |
| 73 | `0xad461ca9595bf8ef5d16d23ba0407f2b74041cec` | 2015-10-15 20:54 | 389212 | self-destructed |
| 74 | `0x4b12409b987fe8cf4f47ae13727087bb9e31b660` | 2015-10-15 21:07 | 389256 | self-destructed |
| 75 | `0x97f097851f3bfc924f02057442a528c7f0acb488` | 2015-10-15 21:53 | 389421 | self-destructed |
| 76 | `0x67ef78b1e010533da63aebd1ead4fa6cbb029eac` | 2015-10-16 05:30 | 390864 | self-destructed |
| 77 | `0x9f2f32e4a67c2c40782a82232c98c78bf48fa9f3` | 2015-10-16 05:34 | 390873 | self-destructed |
| 78 | `0x6917029805e2870e6993893d1be56baf1c8ba309` | 2015-10-16 05:48 | 390911 | self-destructed |
| 79 | `0xb3fa800f1f8a6dbd04e502f35a1c601fe3bf9551` | 2015-10-16 12:38 | 392340 | self-destructed |
| 80 | `0xe61eb898489563e511cd5d3c8e703048002edd1a` | 2015-10-16 20:53 | 394106 | self-destructed |
| 81 | `0x6b9f9353c2a9d83054d3e508517f2d002f07f0bc` | 2015-10-16 21:19 | 394183 | self-destructed |
| 82 | `0xdb3add4285ec7c4368904fbb96e292c82df11048` | 2015-10-17 02:24 | 395272 | self-destructed |
| 83 | `0x90bb10c33ffc9fe58f3d4c81c8ad400df323ffcd` | 2015-10-17 02:26 | 395275 | self-destructed |
| 84 | `0xd9ea81323e4b0f2ba8b1ec1d7cccd848377beedf` | 2015-10-17 06:20 | 396135 | self-destructed |
| 85 | `0xe5d3f78f0b171903bcbc6c8c1cdf1523b4bb5227` | 2015-10-17 18:26 | 398645 | self-destructed |
| 86 | `0xd95f00d25b226b09e0a387bf35823c027501d750` | 2015-10-17 18:33 | 398671 | self-destructed |
| 87 | `0xa2f63e28172ebf2477f4c1a87aed68aaa3ebbe3d` | 2015-10-17 21:45 | 399334 | **exists (v0.85)** |
| 88 | `0x0f8df84b91902100260111b21b02759219358d4f` | 2015-10-17 23:00 | 399580 | self-destructed |
| 89 | `0x6d4fe605bed11bed704554ab136d5ae4eab2fb85` | 2015-10-17 23:24 | 399658 | self-destructed |
| 90 | `0xbb8767b6f6992be46e7dec0b1e4a7da304ff3e16` | 2015-10-17 23:44 | 399731 | self-destructed |
| 91 | `0x66bcc066cd0fe0074f3d18847795ef1b62b58f75` | 2015-10-18 00:00 | 399789 | self-destructed |
| 92 | `0x7887436576949b0210960dc48a4e8ff8b2d9ed5b` | 2015-10-18 00:46 | 399948 | self-destructed |
| 93 | `0x8bdaf3891c254cf1d9c7fddfa0184570783af40b` | 2015-10-18 00:54 | 399971 | self-destructed |
| 94 | `0x94863bbbc12ec5be148f60a7020fd49236fc1937` | 2015-10-18 01:16 | 400048 | never had code |
| 95 | `0x5dc23a8abc3aa4b5992a4bda54988c9e40887651` | 2015-10-18 01:20 | 400069 | self-destructed |
| 96 | `0x4f602ad0f56907466451243083266dadce60cac6` | 2015-10-18 14:01 | 402593 | self-destructed |
| 97 | `0x939340684f59c6ab60e2ca3e110c26591cc05964` | 2015-10-18 15:18 | 402886 | self-destructed |
| 98 | `0xb08ad6a44a8a212e35abf701fa3e5264849da926` | 2015-10-18 17:03 | 403271 | self-destructed |
| 99 | `0x3faad4a6b78eb0df018f6bef7530ae6f9618bc11` | 2015-10-18 19:30 | 403798 | self-destructed |
| 100 | `0x0333b206a0902902a638e24b1227dfcdc2176e78` | 2015-10-18 19:58 | 403903 | self-destructed |
| 101 | `0x96b93e5d82cb6546468d3ee1012896b3ce5dc3fe` | 2015-10-18 20:22 | 403982 | self-destructed |
| 102 | `0x64f5e29c60f833a6432fe818dae1f653e1de9071` | 2015-10-19 02:41 | 405313 | self-destructed |
| 103 | `0xc370681bfdf0408fa084f50853e141950e14ddc5` | 2015-10-19 03:24 | 405453 | self-destructed |
| 104 | `0x55a99538fd0b62b58f9793d6528d5c7753631122` | 2015-10-19 05:37 | 405896 | self-destructed |


</details>

## Part 2: every other account

Every block from 0 to 407,809 was read: 381,359 transactions, including 2,483 contract deployments by
338 accounts. Contracts created by other contracts were found three ways, which together cover every
case:

- Contracts that can create contracts at any time: each one's own transaction count shows how many it
  created, and their addresses follow from it.
- Contracts that created contracts while being deployed: their transaction count right after
  deployment shows this, and the deployment was traced.
- Deployments that left no code but contain a create instruction: the deployment was traced.

That found 37 more contracts, for 2,520 in total. Each contract's code was read as of the end of the
block it was created in.

The creator's 104 contracts are the only ones with a tile function. Contracts from other accounts were
also put through two broader tests:

- **Shared functions.** Does it have any function that appears in any Etheria source (every version,
  the helpers and the later wrappers), not counting generic names such as `withdraw()`? None does.
- **Similar code.** A contract compiled from Etheria's source shares most of its compiled code with
  that version, even if every function is renamed. Each contract was compared with all 104
  Etheria-like contracts, scored from 0 (nothing in common) to 1 (identical). The highest score for
  any contract of 2,000 bytes or more is 0.10. The highest for any contract at all is 0.125, for a
  352-byte contract; the smallest Etheria-like contract is 918 bytes.

## Data and how to check it

`EXHAUSTIVE_PRE_V0pt9_SEARCH.csv` lists all 2,520 contracts: address, block, date, who created it
(account or contract), the deployment transaction, code size at creation, whether it exists today, its
category, its tile functions, any Etheria functions it shares, and (for other accounts) its similarity
score.

Anyone with access to an archive node can check the account figures directly:

- `eth_getTransactionCount` at block 407,809 returns how many transactions each account sent before
  v0.9 (the presale account returns 1,397).
- `eth_getTransactionCount` and `eth_getBalance` at block 778,482 show whether an account existed
  in 2015.

For an independent check of part 2, Google publishes every Ethereum contract in BigQuery. This query
lists every contract created before v0.9, with its function selectors:

```sql
SELECT address, block_number, function_sighashes
FROM `bigquery-public-data.crypto_ethereum.contracts`
WHERE block_number < 407810
ORDER BY block_number
```

Every address it returns should appear in the CSV. This query was not run for this document.

## Limits

- This covers Ethereum mainnet. Test networks are separate chains and have no bearing on mainnet tiles.
- "Etheria-like" means Etheria's functions or Etheria's compiled code. A contract rewritten from
  scratch, with new names and new code, would not be detected, and it would not be Etheria either.
- Function names come from the Etheria sources and a public signature database (openchain.xyz).
  Contracts whose functions have no known names are still covered by the code-similarity test.
- Blocks were read from a Nethermind full node. Historical code, transaction counts, balances and
  traces came from Alchemy's archive node. The search was done on 2026-10-05 and 2026-10-06.
