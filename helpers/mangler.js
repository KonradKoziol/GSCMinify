/**
 * GSCMinifier - Mangler
 * Developed By Liam
 * https://github.com/lierrmm 
 */

function mangle(input) {
    try {
        let mang = new Mangler();
        let output = mang.parseInput(input);
        return output;
    }
    catch(ex) {
        throw ex;
    }
}

class Mangler {
    
    regex_match = /^\w+\(/gmi;
    used_strs = [];
    output = "";

    randomStr = (length) => {
        let result           = '';
        let charsNoNum       = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        let characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let charactersLength = characters.length;
        for ( let i = 0; i < length; i++ ) {
           if(i === 0) result += charsNoNum.charAt(Math.floor(Math.random() * charsNoNum.length));
           else result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
    };

    runMangler = (str) => {
        let _str = this.randomStr(2);
        if(!this.used_strs.includes(_str)) {
            this.used_strs.push(_str);
            let newstr = str.replace("(", "\\(");
            let re = new RegExp(newstr, 'g');
            this.output = this.output.replace(re, `${_str}(`);
            // Check for inlined functions like ::demo
            str = `::${str.substring(0, str.length - 1)}`
            re = new RegExp(str, 'g');
            this.output = this.output.replace(re, `::${_str}`);
        }
        else 
            return this.runMangler(str);
    };

    parseInput = (gsc) => {
        this.output = gsc;
        let doesMatch = this.regex_match.test(this.output);
        if(doesMatch) {
            let matches = this.output.match(this.regex_match);
            matches.forEach(match => {
                this.runMangler(match);
            });
        }
        return this.output;
    };
}


exports.Mangle = mangle;