// usage: node verify_recipe.js [--creation] <soljson file> <file.sol> [<file.sol> ...]
// Compiles the files in order in ONE compiler instance, the way Remix does: each file as a single source under its
// own file name, optimizer on. Prints the runtime bytecode of contract Etheria from the last file, or with
// --creation, its creation bytecode.
const fs = require('fs'), path = require('path');
const args = process.argv.slice(2);
const creation = args[0] === '--creation';
if (creation) args.shift();
const solc = require(path.resolve(args[0]));
const compile = solc.cwrap('compileJSONMulti', 'string', ['string', 'number']);
let out;
for (const file of args.slice(1)) {
    const sources = { [path.basename(file)]: fs.readFileSync(file, 'utf8') };
    out = JSON.parse(compile(JSON.stringify({ sources }), 1)); // 1 = optimizer on
}
const etheria = out.contracts.Etheria;
console.log(creation ? etheria.bytecode : etheria.runtimeBytecode);
