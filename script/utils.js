const http = require("http");
const colors = {
    Reset: "\x1b[0m",
    Bright: "\x1b[1m",
    Dim: "\x1b[2m",
    Underscore: "\x1b[4m",
    Blink: "\x1b[5m",
    Reverse: "\x1b[7m",
    Hidden: "\x1b[8m",

    FgBlack: "\x1b[30m",
    FgRed: "\x1b[31m",
    FgGreen: "\x1b[32m",
    FgYellow: "\x1b[33m",
    FgBlue: "\x1b[34m",
    FgMagenta: "\x1b[35m",
    FgCyan: "\x1b[36m",
    FgWhite: "\x1b[37m",

    BgBlack: "\x1b[40m",
    BgRed: "\x1b[41m",
    BgGreen: "\x1b[42m",
    BgYellow: "\x1b[43m",
    BgBlue: "\x1b[44m",
    BgMagenta: "\x1b[45m",
    BgCyan: "\x1b[46m",
    BgWhite: "\x1b[47m",
}

/**
 * Colorises a given string.
 * @param {string} str
 * @param {string} color
 * @returns {string}
 */
function colorise(str, ...color) {
    return color.join('') + str + colors.Reset;
}

/**
 * Gets the process arguments and parses them into an object.
 * @returns {object}
 */
function getArgs() {
    const args = process.argv.slice(2).reduce((result, v) => {
        if (v.startsWith("-") || v.startsWith("--")) {
            v = v.replace(/^--?/, "");
            result._previousValue = v;
            result[v] = true;
        }
        else if (result._previousValue != null) {
            if (v == "true") v = true;
            else if (v == "false") v = false;
            else {
                const num = parseFloat(v);
                if (!isNaN(num)) { v = num; }
            }

            result[result._previousValue] = v;
            result._previousValue = null;
        }
        return result;
    }, { _previousValue: null });
    delete args._previousValue;
    return args;
}

/**
 * Gets server's local IP address
 * @returns {string}
 */
function getLocalIp() {
    const { networkInterfaces } = require('os');
    const netFamilies = ['IPv4', 4];
    return networkInterfaces().en0?.find(net => !net.internal && netFamilies.includes(net.family))?.address || '<unknown-ip>';
}

/**
 * Extracts a file path from the given URL.
 * @param {string} url
 * @returns {string}
 */
function getPathFromUrl(url) {
    const queryPos = url.indexOf("?");
    return url.substring(1, queryPos > -1 ? queryPos : url.length);
}

/**
 * Returns the current time already formatted.
 */
function getTime() {
    return new Date().toUTCString();
}

/**
 * Checks if the given item is an object.
 * @param {any} item
 * @returns {boolean}
 */
function isObject(item) {
    return (item && typeof item === 'object' && !Array.isArray(item));
}

/**
 * Logs into the node console.
 * @param {any} message
 */
function log(message) {
    console.log(`[${getTime()}] ${message}`);
}

/**
 * Logs into the node console.
 * @param {any} message
 * @param {string} color
 */
function logColor(message, color) {
    log(colorise(message, color));
}

/**
 * Deep merge two objects.
 * @param {object} target
 * @param {...object} sources
 * @returns {object}
 */
function mergeDeep(target, ...sources) {
    if (!sources.length) return target;
    const source = sources.shift();

    if (isObject(target) && isObject(source)) {
        for (const key in source) {
            if (isObject(source[key])) {
                if (!target[key]) Object.assign(target, { [key]: {} });
                mergeDeep(target[key], source[key]);
            } else {
                Object.assign(target, { [key]: source[key] });
            }
        }
    }

    return mergeDeep(target, ...sources);
}

/**
 * Writes JSON into an HTTP ServerResponse.
 * @param {http.ServerResponse} res
 * @param {number} statusCode
 * @param {any} rawResponse
 * @returns {ServerResponse}
 */
function respond(res, statusCode, rawResponse) {
    res.writeHead(statusCode, { "Content-Type": "application/json" });
    res.end(rawResponse != null ? JSON.stringify(rawResponse) : undefined);
    return res;
}

module.exports = { colors, colorise, getArgs, getLocalIp, getPathFromUrl, getTime, isObject, log, logColor, mergeDeep, respond };
