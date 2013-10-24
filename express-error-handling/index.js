var createApp = require('./app');
var uncaughtHandler = require('./uncaught_handler');
var app = createApp();

process.on('uncaughtException', function (error) {
  uncaughtHandler(error, app, process);
});

