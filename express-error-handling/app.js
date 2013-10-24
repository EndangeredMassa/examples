var express = require('express');
var http = require('http');
var expressLogger = require('./express_logger');
var Domain = require('domain');
var lastResortExit = require('./last_resort');

module.exports = function () {
  var app = express();
  app.get('/', function (req, res) {
    res.send('hello world');
  });

  app.get('/error', function (request, response) {
    throw new Error('you went to /error, silly!');
  });

  app.get('/asyncerror', function (request, response) {
    setTimeout(function () {
      throw new Error('you went to /asyncerror, silly!');
    }, 100);
  });

  app.get('/domainerror', function (request, response) {
    var domain = Domain.create();
    domain.on('error', function (error) {
      lastResortExit(process);
      expressLogger(error, request, function () {
        process.exit(150);
      });
    });
    domain.run(function () {
      setTimeout(function () {
        throw new Error('you went to /domainerror, silly!');
      }, 100);
    });
  });

  app.use(function (error, request, response, next) {
    expressLogger(error, request, next);
    response.status = 500;
    response.end();
  });

  var server = http.createServer(app);
  server.listen(5555);
  console.log('listening on localhost:5555');

  return server
};
