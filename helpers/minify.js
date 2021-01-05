/**
 * GSCMinifier
 * Developed By Liam
 * https://github.com/lierrmm 
 */

function minify(input, options = []) {
    try {
        let shrink = new Minifier();
        let output = shrink.minifyDirectToOutput(input, options);
        return output;
    }
    catch(ex) {
        throw ex;
    }
}


class Minifier {
    input;
    len = 0;
    index = 0;
    firstChar = '';
    secondChar = '';
    thirdChar = undefined;
    options = {};
    stringDelimiters = {
        '\'': true,
        '"': true,
        '`': true
    };
    defaultOptions = {
        'flaggedComments': true
    };

    noNewLineCharacters = {
        '(': true,
        '-': true,
        '+': true,
        '[': true,
        '@': true};
    output = '';

    getChar = () => {
        let char = undefined;
        if (typeof this.thirdChar !== "undefined" && this.thirdChar.length > 0) {
            char = this.thirdChar;
            this.thirdChar = undefined;
        } else {
            char = this.index < this.len ? this.input[this.index] : false;

            if (typeof char !== "undefined" && char === false) {
                return false;
            }

            this.index++;
        }

        if (char !== "\n" && char < "\x20") {
            return ' ';
        }

        return char;
    }

    getNext = (str) => {
        let pos = this.input.indexOf(str, this.index);

        if (pos === -1) return false;

        this.index = pos;

        return this.index < this.len ? this.input[this.index] : false;
    };

    processOneLineComments = (startIndex) => {
        let thirdCommentString = this.index < this.len ? this.input[this.index] : false;

        this.getNext("\n");

        this.thirdChar = undefined;

        if (thirdCommentString == '@') {
            let endPoint = this.index - startIndex;
            this.thirdChar = "\n" + this.input.substring(startIndex, endPoint);
        }
    };

    processMultiLineComments = (startIndex) => {
        this.getChar();
        let thirdCommentString = this.getChar();
        let char;
        if (this.getNext('*/')) {
            this.getChar();
            this.getChar();
            char = this.getChar();
        } else {
            char = false;
        }

        if (char === false) {
            throw Error("Unclosed multiline comment at position: " + (this.index - 2));
        }

        this.thirdChar = char;
    }

    getReal = () => {
        let startIndex = this.index;
        let char = this.getChar();

        if (char !== '/') return char;

        this.thirdChar = this.getChar();

        if (this.thirdChar === '/') {
            this.processOneLineComments(startIndex);
            return this.getReal();
        } else if (this.thirdChar === '*') {
            this.processMultiLineComments(startIndex);
            return this.getReal();
        }

        return char;
    };

    saveString = () => {
        let startpos = this.index;

        this.firstChar = this.secondChar;

        if (typeof this.stringDelimiters[this.firstChar] === "undefined") return;
        let stringType = this.firstChar;

        this.output += this.firstChar;

        loop1:
            while ((this.firstChar = this.getChar()) !== false) {
                    switch (this.firstChar) {
                        case stringType:
                            break loop1;
                        case "\n":
                            if (stringType === '`') {
                                this.output += this.firstChar;
                            } else {
                                throw Error('Unclosed string at position: ' + startpos);
                            }
                            break;
                        case "\\":
                            this.secondChar = this.getChar();
                            if (this.secondChar === "\n") break;
                            this.output +=  this.firstChar + this.secondChar;
                            break;
                        default:
                            this.output +=  this.firstChar;
                            break;
                    }
                }
            }

        initialise = (gsc, options) => {
            this.options = this.defaultOptions;
            this.input = gsc.replace("\r\n", "\n");
            this.input = this.input.replace("/**/", "");
            this.input = this.input.replace("\r", "\n");

            this.len = this.input.length;

            this.firstChar = "\n";
            this.secondChar = this.getReal();

        };

        saveRegex = () => {
            this.output += (this.firstChar + this.secondChar);
            while ((this.firstChar = this.getChar()) !== false) {
                if (this.firstChar === '/') {
                    break;
                }
    
                if (this.firstChar === '\\') {
                    this.output += this.firstChar;
                    this.firstChar = this.getChar();
                }
    
                if (this.firstChar === "\n") {
                    throw new Error('Unclosed regex pattern at position: ' . this.index);
                }
    
                this.output += this.firstChar;
            }

            this.secondChar = this.getReal();
        }

        loop = () => {
            while (this.firstChar !== false && this.firstChar !== undefined && this.firstChar !== null && this.firstChar.length > 0) {
                switch (this.firstChar) {
                    case "\n":
                        if (this.secondChar !== false && typeof this.noNewLineCharacters[this.secondChar] !== "undefined") {
                            this.saveString();
                            break;
                        }

                        if (this.secondChar === ' ') {
                            // this.output += this.secondChar;
                            break;
                        }

                    case ' ':
                        if (/^[\w\$\pL]$/.test(this.secondChar) === true || this.secondChar == "/") {
                            this.output +=  this.firstChar;
                        }

                        this.saveString();
                        break;
                    default:

                        switch (this.secondChar) {
                            case "\n":
                                if ('}])+-"\''.indexOf(this.firstChar) !== -1) {
                                    this.output +=  this.firstChar;
                                    this.saveString();
                                    break;
                                } else {
                                    if (/^[\w\$\pL]$/.test(this.firstChar) === true || this.firstChar === "/") {
                                        this.output +=  this.firstChar;
                                        this.saveString();
                                    }
                                }
                                break;
                            case ' ':
                                if (/^[\w\$\pL]$/.test(this.firstChar) === false && this.firstChar !== "/") {
                                    break;
                                }
                            default:
                                if(this.firstChar === '/' && (this.secondChar === '\'' || this.secondChar === '"')) {
                                    this.saveRegex();
                                    continue;
                                }

                                this.output +=  this.firstChar;
                                this.saveString();
                                break;
                        }
                }
                this.secondChar = this.getReal();

                if(this.secondChar === '/' && '(,=:[!&|?'.indexOf(this.firstChar) !== -1) {
                    this.saveRegex();
                }
            }
        };

        clean = () => {
            this.input = '';
            this.len = 0;
            this.index = 0;
            this.firstChar = '';
            this.secondChar = '';
            this.thirdChar = undefined;
            this.options = undefined;
        }

        minifyDirectToOutput = (gsc, options) => {
            this.initialise(gsc, options);
            this.loop();
            this.clean();
            return this.output;
        };
    };



    exports.Minify = minify;