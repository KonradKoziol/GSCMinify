const fs = require('fs');
const path = require('path');
const prompt = require('prompt');
const optimist = require('optimist');
const minifier = require('./helpers/minify');
const mangler = require('./helpers/mangler');

prompt.override = optimist.argv;

let filePath = "";

prompt.start();

prompt.get(['input'], function (err, result) {
    try {
        if(err) return console.error(err);
        
        filePath = result.input;

        if(filePath.length <= 0) return console.warn("No Input File Specified.");

        const inputFile = fs.readFileSync(filePath, { encoding: 'utf-8' }); 
        
        if(inputFile.length <= 0) return console.warn("No Input File Specified.");

        // Mangle First

        let mangled = mangler.Mangle(inputFile);
        if(mangled.length <= 0) return console.warn("Could not mangle file. Exiting.");
        console.log(">", `Mangled ${inputFile.length} Bytes into ${mangled.length} Bytes. Saving ${Math.abs((100 - (mangled.length/inputFile.length) * 100)).toFixed(2)}%`);
        
        // Minify 

        let minified = minifier.Minify(mangled);
        if(minified.length <= 0) return console.warn("Could not minify file. Exiting.");
        console.log(">", `Minified ${mangled.length} Bytes into ${minified.length} Bytes. Saving ${Math.abs((100 - (minified.length/mangled.length) * 100)).toFixed(2)}%`);

        // Calculate total

        let mangledValue = Math.abs((100 - (mangled.length/inputFile.length) * 100));
        let minifiedValue = Math.abs((100 - (minified.length/mangled.length) * 100));

        let totalValue = mangledValue + minifiedValue;

        console.log(">", `Saved ${totalValue.toFixed(2)}% in total.`);
        let outputFilePath = `${path.dirname(filePath)}/${path.parse(filePath).name}.min.gsc`;
        fs.writeFileSync(outputFilePath, minified);

        console.log(">", `Wrote output to ${outputFilePath}`);
        console.log(">", "Exiting..");
        process.exit(0);
    }
    catch(err) {
        console.error(err.message);
        process.exit(0);
    }
});