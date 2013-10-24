var logError = require('./log_error');
var airbrake = require('airbrake').createClient('MY AIRBRAKE KEY', 'development');

var mixinRequest = function (error, request) {
  if (request.url)
    error.url = request.url;
  if (request.component)
    error.component = request.component;
  if (request.method)
    error.action = request.method;
  if (request.params && request.params.length > 0)
    error.params = request.params;
  if (request.session)
    error.session = request.session;

  if(!error.stack)
    error.stack = '';
};

var lastChanceLog = function (originalError, errorHandlerError) {
  originalError = JSON.stringify(originalError, ['stack']);
  errorHandlerError = JSON.stringify(errorHandlerError, ['stack']);

  var timestamp = new Date().toISOString();
  var message = '[' + timestamp + '] Unhandled Error in Error Handler: ErrorHandlerError=' + errorHandlerError + ' Original=' + originalError;
  console.error(message);
};

module.exports = function (error, request, callback) {
  if (null == request)
    request = {};

  try {
    mixinRequest(error, request);
    logError(error);
    if (!(process.env.NODE_ENV === 'development' || process.env.NODE_ENV === 'test')) {
      airbrake.notify(error, function (airbrakeError) {
        if (null != airbrakeError)
          logError(airbrakeError);
        if ('function' === typeof callback)
          callback();
      });
    } else if ('function' === typeof callback) {
      callback();
    }
  } catch (loggerError) {
    lastChanceLog(error, loggerError);
  }
};

