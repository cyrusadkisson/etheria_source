# Reproducing Etheria's bytecode

Etheria v0.9, v1.0, v1.1 and v1.2 were compiled with solc 0.1.6, whose output depends on more than the
source. It also depends on the compiler's memory state, which is set by the exact input text (comments
and whitespace included) and by everything the same compiler instance compiled before. The contracts
were compiled in a browser compiler that recompiled as the source was edited, so compiling a source
once does not reproduce its bytecode.

Each version has a recipe: files to compile in order, in one compiler instance. The last compile
produces the deployed runtime and creation bytecode exactly.

| Version | Contract | Compile in this order |
|---|---|---|
| v0.9 | `0xe468d26721b703d224d05563cb64746a7a40e1f4` | [`etheria-0pt9_0xe46.sol`](../etheria-0pt9_0xe46.sol) four times |
| v1.0 | `0xe414716f017b5c1457bf98e985bccb135dff81f2` | [`v1pt0/`](v1pt0/): `17584309.sol`, `21498383.sol`, `etheria.sol` |
| v1.1 | `0x169332ae7d143e4b5c6baedb2fef77bfbddb4011` | [`etheria-1pt1_0x169.sol`](../etheria-1pt1_0x169.sol) twice |
| v1.2 | `0xb21f8684f23dbb1008508b4de91a0aaedebdb7e4` | [`v1pt2/`](v1pt2/): `forwarder.sol`, `31209352.sol`, `etheria.sol` |

For v0.9 and v1.1, compiling the source file itself enough times is all it takes. v1.0 and v1.2 also
need two helper contracts that have nothing to do with Etheria, followed by a copy of the source padded
with lines of spaces at the top and bottom. Between its padding lines, each `etheria.sol` is the source
in [`etheria-1pt0_0xe41.sol`](../etheria-1pt0_0xe41.sol) or [`etheria-1pt2_0xb21.sol`](../etheria-1pt2_0xb21.sol)
(v1.0's copy has Windows line endings). The helpers and padding lengths were found by random search:
v1.2's by [Dedaub](https://dedaub.com) in Nov 2021, and v1.0's the same way in Jan 2023. The `README` in
each of those folders has the original instructions. The helpers are small public example contracts,
some of them deliberately buggy examples from security write-ups, used here only because compiling them
leaves the compiler in the right state; they are not part of Etheria and were never deployed by it.

**Do not edit, reformat or re-save any file in a recipe**, including the v0.9 and v1.1 source files. Any
change, even to a comment, whitespace or line endings, can break the match. The repository's
`.gitattributes` stops git from converting the line endings of `.sol` files and of the compiler file.

The test contracts from before v0.9 have their own instructions in
[`NKNVELSC/README.md`](../NKNVELSC/README.md#how-to-verify).

## In Remix

1. Upload the recipe's files into the root of a Remix workspace (not under `contracts/`), keeping their
   names. Upload them rather than pasting, so nothing is altered.
2. Select compiler 0.1.6+commit.d41f8b7c and turn on optimization.
3. Compile the files in the order above. For v0.9 and v1.1, compile the same file again until you have
   compiled it the number of times listed.

## From the command line

You need [Node.js](https://nodejs.org); nothing else to install. The compiler is in
[`compiler/`](compiler/): an unchanged copy of `soljson-v0.1.6+commit.d41f8b7c.js` from
[ethereum/solc-bin](https://github.com/ethereum/solc-bin), with its SHA-256
(`b2fcb4f707ad6545c8a65b70164c59d4555cd607b97204844d51a803917a4549`), IPFS address and license.

[`verify_recipe.js`](verify_recipe.js) compiles the files you give it in order, in one compiler
instance, the way Remix does: each file as a single source under its own name, optimizer on. It prints
the runtime bytecode of `Etheria` from the last file. From this folder:

```
node verify_recipe.js compiler/soljson-v0.1.6+commit.d41f8b7c.js v1pt2/forwarder.sol v1pt2/31209352.sol v1pt2/etheria.sol
node verify_recipe.js compiler/soljson-v0.1.6+commit.d41f8b7c.js ../etheria-1pt1_0x169.sol ../etheria-1pt1_0x169.sol
```

Node prints an `Invalid asm.js` warning, which is harmless. The result depends only on the compiler
file and the files compiled, not on the Node version or machine: the compiler manages its memory itself,
inside the file. The recipes were found in browsers in 2021 and 2023 and checked with Node 24.13.1 in
2026.

Compare the output with the contract's code on chain (`eth_getCode`, without the `0x`). With
`--creation` before the compiler file, it prints the creation bytecode instead, which equals the input
of the deployment transaction.

## Etherscan

All four versions are verified on Etherscan; v1.2 was verified in Nov 2021 and v1.0 in Feb 2023 from
the padded files here. The copies Etherscan shows for those two have altered padding at the top; v1.2's
has lost the line break after its first padding line, so it does not compile as shown. Use the files
here instead.
