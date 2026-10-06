# NKNVELSC

**N**on-**K**illable, **N**on-**V**iable, **E**theria-**L**ike **S**mart **C**ontracts.

These are four test versions of Etheria that were deployed to mainnet in late 2015, before the
first-viable, still-extant Etheria v0.9. None of them has a `kill()` function, so they will stay on the chain forever.
Each one has a fatal bug, so none of them is a usable Etheria.

**There is no wrapper and no official website for any of these contracts. Anything offering tiles,
wrapped tokens or trading for these addresses is a scam.**

| File | Version | Address | Deployed (UTC) | Fatal bug |
|---|---|---|---|---|
| `etheria-0pt6_0x648.sol` | v0.6 | `0x6489fc370c7df314ee0bdfb1fbd185f1bc457d89` | block 314103, 2015-09-30 21:37 | Every tile is owned by a corrupted address nobody controls (`addBlock` overwrote the stored creator address), and `setOwner` uses `==` instead of `=`. Tiles can never be transferred. |
| `etheria-0pt7_0x014.sol` | v0.7 | `0x0148368e9efd8d6a5dd56134cd2b3f941e10d953` | block 383700, 2015-10-14 18:08 | `acceptOffer` has no owner check, so anyone can accept any offer on any tile |
| `etheria-0pt8_0xcf1.sol` | v0.8 | `0xcf1eecf5929c151427dc3662a28353266ea3f9e6` | block 385709, 2015-10-15 03:55 | `acceptOffer` has no owner check, so anyone can accept any offer on any tile |
| `etheria-0pt85_0xa2f.sol` | v0.85 | `0xa2f63e28172ebf2477f4c1a87aed68aaa3ebbe3d` | block 399334, 2015-10-17 21:45 | `makeOffer` lets anyone take a tile that hasn't been farmed in 100,000 blocks for 1 ETH (paid to the creator), and `acceptOffer` has no owner check |

**Were there any others?** No. [EXHAUSTIVE_PRE_V0pt9_SEARCH.md](EXHAUSTIVE_PRE_V0pt9_SEARCH.md) checks every
contract deployed on Ethereum mainnet before v0.9. These four are the only Etheria-like contracts
from before v0.9 that still exist.

Each file starts with a comment that explains the bug in detail and gives the address and ABI.
Below the comment is source code that compiles to exactly the bytecode on the chain:

| Version | Compiler (optimizer on) |
|---|---|
| v0.6 | solc 0.1.4 (also 0.1.3) |
| v0.7 | solc 0.1.5 (release or 2015-10-13 nightly; also 0.1.6, 0.1.7) |
| v0.8 | solc 0.1.5 (release or 2015-10-13 nightly; also 0.1.6, 0.1.7) |
| v0.85 | solc 0.1.6 (also 0.1.5 nightlies of 2015-10-13/15/16 and 0.1.7; not the 0.1.5 release) |

v0.7 and v0.85 were deployed from uncommitted working copies of the etheriaSource repo. Their sources here are reconstructions
that match byte for byte, and the file comments describe how each one differs from the nearest
commits in the original development repo.

## How to verify

You need [Node.js](https://nodejs.org) and a copy of this folder.

1. Download the compiler. These old versions only exist as `soljson` builds in
   [ethereum/solc-bin](https://github.com/ethereum/solc-bin). Two files cover all four contracts:
   - v0.6: https://binaries.soliditylang.org/bin/soljson-v0.1.4+commit.5f6c3cdf.js
   - v0.7, v0.8 and v0.85: https://binaries.soliditylang.org/bin/soljson-v0.1.5-nightly.2015.10.13+commit.e11e10f8.js

   Any build listed in the table above also works for its version.

2. Save this as `verify.js`:

   ```js
   // usage: node verify.js <soljson file> <.sol file>
   // Prints the runtime bytecode of contract Etheria. One compile per run (a fresh compiler instance).
   const fs = require('fs'), path = require('path');
   const solc = require(path.resolve(process.argv[2]));
   const compile = solc.cwrap('compileJSON', 'string', ['string', 'number']);
   const out = JSON.parse(compile(fs.readFileSync(process.argv[3], 'utf8'), 1)); // 1 = optimizer on
   console.log(out.contracts.Etheria.runtimeBytecode);
   ```

3. Compile a file, for example v0.7:

   ```
   node verify.js soljson-v0.1.5-nightly.2015.10.13+commit.e11e10f8.js etheria-0pt7_0x014.sol
   ```

   It prints the runtime bytecode as hex. Node also prints an `Invalid asm.js` warning, which is harmless.

4. Compare the output with the `chain:` line in the file's header comment, which is the deployed
   bytecode (without the `0x`). To check against the chain itself, ask any Ethereum node for the
   contract's code; the result is `0x` followed by the same hex:

   ```
   curl -s -X POST -H 'Content-Type: application/json' \
     --data '{"jsonrpc":"2.0","id":1,"method":"eth_getCode","params":["0x0148368e9efd8d6a5dd56134cd2b3f941e10d953","latest"]}' \
     <your node's RPC URL>
   ```

Compile each file exactly as it is (header comment included), one compile per run, as `verify.js`
does. These old compilers' output can depend on the whole file text, comments included, and on
anything the same compiler instance compiled before, so an edited copy or a reused instance may not
reproduce the match.
