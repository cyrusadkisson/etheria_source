# Verification recipes for Etheria v1.0 and v1.2

Etheria v1.0 and v1.2 were compiled with solc 0.1.6, whose output depends on more than the source. It
also depends on the compiler's memory state, which is set by the exact input text (comments and
whitespace included) and by everything the same compiler instance compiled before. Both contracts were
compiled in a browser compiler that had been recompiling as the source was edited, so compiling the
source once does not reproduce their bytecode.

These recipes recreate that state. Each folder holds three files:

- two small helper contracts that have nothing to do with Etheria, padded with lines of spaces
- `etheria.sol`, the Etheria source padded the same way

Compiling the two helpers and then `etheria.sol`, in that order and in one compiler instance, produces
the deployed runtime and creation bytecode exactly. The helper contracts and padding lengths were found
by random search: v1.2's by [Dedaub](https://dedaub.com) in Nov 2021, and v1.0's the same way in Jan 2023.

| Folder | Contract | Compile in this order |
|---|---|---|
| [`v1pt0/`](v1pt0/) | v1.0, `0xe414716f017b5c1457bf98e985bccb135dff81f2` | `17584309.sol`, `21498383.sol`, `etheria.sol` |
| [`v1pt2/`](v1pt2/) | v1.2, `0xb21f8684f23dbb1008508b4de91a0aaedebdb7e4` | `forwarder.sol`, `31209352.sol`, `etheria.sol` |

Between its padding lines, each `etheria.sol` is the source in
[`etheria-1pt0_0xe41.sol`](../etheria-1pt0_0xe41.sol) or [`etheria-1pt2_0xb21.sol`](../etheria-1pt2_0xb21.sol)
(v1.0's copy has Windows line endings). Each folder's `README` has the original instructions.

**Do not edit, reformat or re-save these files.** Any change, even to whitespace or line endings, breaks
the match. The `.gitattributes` in this folder stops git from converting line endings.

## In Remix

1. Upload the three files into the root of a Remix workspace (not under `contracts/`), keeping their
   names. Upload them rather than pasting, so nothing is altered.
2. Select compiler 0.1.6+commit.d41f8b7c and turn on optimization.
3. Compile the two helper files in the order above, then `etheria.sol`.

## From the command line

You need [Node.js](https://nodejs.org) and the compiler, which exists only as a `soljson` build in
[ethereum/solc-bin](https://github.com/ethereum/solc-bin):
https://binaries.soliditylang.org/bin/soljson-v0.1.6+commit.d41f8b7c.js

[`verify_recipe.js`](verify_recipe.js) compiles the files you give it in order, in one compiler
instance, the way Remix does: each file as a single source under its own name, optimizer on. It prints
the runtime bytecode of `Etheria` from the last file:

```
node verify_recipe.js soljson-v0.1.6+commit.d41f8b7c.js v1pt2/forwarder.sol v1pt2/31209352.sol v1pt2/etheria.sol
```

Compare the output with the contract's code on chain (`eth_getCode`, without the `0x`). With
`--creation` before the compiler file, it prints the creation bytecode instead, which equals the input
of the deployment transaction.

## Etherscan

Etherscan verified v1.2 in Nov 2021 and v1.0 in Feb 2023 from these padded files. The copies Etherscan
shows have altered padding at the top; v1.2's has lost the line break after its first padding line, so
it does not compile as shown. Use the files here instead.
