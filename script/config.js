const args = require("./utils").getArgs();

module.exports = {
    httpPort: typeof args.port == "number" && !isNaN(args.port) ? args.port : 4567,
    rootPath: typeof args.rootPath == "string" ? args.rootPath : "../../"
};
