var logError = require('./log_error');
var expressLogger = require('./express_logger');
var lastResortExit = require('./last_resort');

var serverRunning = function (server) {
  return !!server.address();
};

var closeServer = function (server) {
  if (serverRunning(server))
    server.close();
};

var thirdPartyLog = function (error, callback) {
  expressLogger(error, null, callback);
};

module.exports = function (error, server, process) {
  lastResortExit(process);
  closeServer(server);
  thirdPartyLog(error, function () {
    process.exit(1);
  });
};

