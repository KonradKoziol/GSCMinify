/**
 * GSCMinifier - Outliers
 * Developed By Liam
 * https://github.com/lierrmm 
 */

var regex_match = /^\w+\(/gmi;
var _output = "";
var outliers = [];
var results = [];

 function mangle(input) {
    try {
        let output = parseInput(input);
        return output;
    }
    catch(ex) {
        throw ex;
    }
}



runOutlier = (str) => {
    let origstr = str;
    let newstr = str.replace("(", "\\(");
    let re = new RegExp(newstr, 'g');
    let count = (_output.match(re) || []).length;
    results.push({ item: str, count: count });
    // Check for inlined functions like ::demo
    str = `::${str.substring(0, str.length - 1)}`
    re = new RegExp(str, 'g');
    count = (_output.match(re) || []).length;
    let index = results.findIndex(x => x.item === origstr);
    if(index <= -1 && count > 0) {
        results.push({ item: str, count: count });
    } else {
        if (count > 0) results[index].count++;
    }
};

parseInput = (array) => {
    array.forEach(function(gsc) {
        _output = gsc;
        let doesMatch = regex_match.test(_output);
        if(doesMatch) {
            let matches = _output.match(regex_match);
            matches.forEach(match => {
                runOutlier(match);
            });
        }
    });

    outliers = results.filter(x => x.count <= 1);
    return { results, outliers };
};

exports.Mangle = mangle;