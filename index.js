const readline = require("readline");
const path = require('path');
const fs = require('fs');
const minifier = require('./helpers/minify');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

let filePath = "";
let outputFilePath = "";

rl.question("Enter Input File Path: ", function(path) {
    filePath = path;
    rl.question("Enter Output File Path: ", function(path) {
        outputFilePath = path;
        rl.close();
    });
});

rl.on("close", function() {
    try {
        if(filePath.length > 0 && outputFilePath.length > 0) {
            console.log("Input", filePath);
            console.log("Output", outputFilePath);
            const inputFile = fs.readFileSync(filePath, { encoding: 'utf-8' }); 
            if(inputFile.length > 0) {
                console.log("Grabbed", inputFile.length, "Bytes from", filePath);
                let response = minifier.Minify(inputFile, []);
                if(response.length > 0) {
                    fs.writeFileSync(outputFilePath, response);
                    console.log("Wrote", response.length, "Bytes to", outputFilePath);
                    console.log("Total Savings of", Math.abs((100 - (response.length/inputFile.length) * 100)).toFixed(2) + "%");
                }
            }
        }
        process.exit(0);
    } catch(e) {
        console.log(e);
    }
});



// const wasm_exec_js = path.join(npmWasmDir, 'wasm_exec.js')
// const wasmExecMin = childProcess.execFileSync(esbuildPath, [
//     wasm_exec_js,
//     '--minify',
//   ], { cwd: repoDir }).toString()
//   const commentLines = fs.readFileSync(wasm_exec_js, 'utf8').split('\n')
//   const firstNonComment = commentLines.findIndex(line => !line.startsWith('//'))
//   const wasmExecMinCode = '\n' + commentLines.slice(0, firstNonComment).concat(wasmExecMin).join('\n')