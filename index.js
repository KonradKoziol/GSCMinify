const fs = require('fs');
const path = require('path');
const prompt = require('prompt');
const optimist = require('optimist');
const minifier = require('./helpers/minify');
const mangler = require('./helpers/mangler');
const outlier = require('./helpers/outliers');

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

prompt.get(["search"], function(err, result) {
    try {
        if(err) return console.error(err);
        filePath = result.search;

        if(filePath.length <= 0) return console.warn("No Input Folder Specified.");

        const inputFile = fs.readdirSync(filePath, { encoding: 'utf-8' }); 
        
        if(inputFile.length <= 0) return console.warn("No Folder Specified.");

        let fileText = [];

        for (file of inputFile) {
            let text = fs.readFileSync(`${filePath}${file}`, { encoding: 'utf-8' });
            text = text.trim();
            fileText.push(text);
        }
        let responses = outlier.Mangle(fileText);
        fs.writeFileSync("./info.json", JSON.stringify(responses.results, null, 2));
        
        if (responses.outliers.length > 0) {
            fs.writeFileSync("./outliers.json", JSON.stringify(responses.outliers, null, 2));
            console.log(">", `Wrote possible outliers to ./outliers.json.`);
        } else {
            console.log(">", `Found no possible outliers. Skipping.`);
        }
        console.log(">", `Wrote results to ./info.json.`);
        console.log(">", "Exiting..");
        process.exit(0);
    }
    catch(err) {
        console.error(err);
        process.exit(0);
    }
});