const config = require("./config");
const querystring = require('querystring');
const { colors, getLocalIp, logColor, mergeDeep, respond } = require("./utils");

// Dependencies.
const fs = require("fs");
const path = require("path");
const http = require("http");

// Instantiate all server instances.
const server = http.createServer(handleRequest);

// Start those instances.
logColor(`Starting server on ip:port ${getLocalIp()}:${config.httpPort}, using rootPath "${path.join(__dirname, config.rootPath)}"`, colors.FgCyan);
server.listen(config.httpPort);

// Request handler.
function handleRequest(req, res) {
    const { headers, method, url } = req;
    const urlPath = url;
    logColor(`:: Incoming request: /${urlPath}`, colors.FgYellow);
    if ((method === 'GET') && urlPath.includes('/deeplink/')) {
        handleDeeplink(urlPath, req, res);
        return;
    }
    if ((method === 'POST') && urlPath.includes('/echo/')) {
        handlePost(urlPath, req, res);
        return;
    }
    // Get config file and validate it
    const configPath = path.join(__dirname, config.rootPath, urlPath);
    if (!fs.existsSync(configPath)) {
        logColor(`:: !404 File not found: ${configPath}`, colors.FgRed);
        respond(res, 404, { message: "File not found" });
        return;
    }
    if (!configPath.endsWith(".json")) {
        logColor(`:: !400 Unsupported file format: ${configPath}`, colors.FgRed);
        respond(res, 400, { message: "Unsupported file format" });
        return;
    }

    // Config file exists, get parent
    const parentConfigPath = path.join(path.dirname(configPath), "../", "config.json");
    logColor(`::: Attempting to find parent: ${parentConfigPath}`, colors.FgGreen);
    if (!fs.existsSync(parentConfigPath)) {
        logColor(`:: !404 Parent file not found: ${parentConfigPath}`, colors.FgRed);
        respond(res, 404, { message: "Parent file not found" });
        return;
    }

    // Parent file exists, merge both
    let response = null;
    try {

        response = mergeDeep({}, ...[
            JSON.parse(fs.readFileSync(parentConfigPath)),
            JSON.parse(fs.readFileSync(configPath))
        ]);
    }
    catch (e) {
        logColor(`:: !Error occurred while parsing files: "${e}"`, colors.FgRed);
        respond(res, 500, { message: "Error processing config files", error: e.toString() });
        return;
    }

    // Serve merged config
    logColor(`::: 200 Serving merged config: ${configPath} `, colors.FgGreen);
    respond(res, 200, response);

}
function handleDeeplink(urlPath, req, res) {
    try {
        const fullUrl = new URL(urlPath, `http://${req.headers.host}`),
            urlParams = fullUrl.searchParams,
            host = urlParams.get('host'),
            app = urlParams.get('app'),
            contentId = encodeURIComponent(urlParams.get('contentId')),
            mediaType = urlParams.get('mediaType'),
            url = `http://${host}/launch/${app}?contentId=${contentId}&mediaType=${mediaType}`

        let request = require('request');
        request.post(url);

        console.log("================deeplink==========================")
        console.log(`URL: \x1b[92m${url}\x1b[0m`);
        console.log("==============deeplink-end==========================")

        return respond(res, 200, {});
    } catch (er) {
        res.statusCode = 400;
        return res.end(`error: ${er.message}`);
    }
}
function handlePost(urlPath, req, res) {

    let body = [];
    // Readable streams emit 'data' events once a listener is added.
    req.on('data', (chunk) => {
        body.push(chunk)
    });

    // The 'end' event indicates that the entire body has been received.
    req.on('end', () => {
        try {
            const parsedBody = querystring.parse(Buffer.concat(body).toString());

            const keys = Object.keys(parsedBody).sort(function(first, second) {
                return first.localeCompare(second);
            });

            console.log("================start==========================")
            keys.forEach((key) => {
                console.log(`${key}: \x1b[92m${parsedBody[key]}\x1b[0m`);
            });
            console.log("==================end==========================")

            return respond(res, 200, {});
        } catch (er) {
            res.statusCode = 400;
            return res.end(`error: ${er.message}`);
        }
    });
}
