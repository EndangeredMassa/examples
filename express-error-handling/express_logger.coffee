logError = require './log_error'
airbrake = require('airbrake')
  .createClient('MY AIRBRAKE KEY', 'development')

module.exports = (error, request={}, callback) ->
  try
    mixinRequest(error, request)
    logError error

    if process.env.NODE_ENV not in ['development', 'test']
      airbrake.notify error, (airbrakeError) =>
        logError airbrakeError if airbrakeError?
        callback?()
    else
      callback?()
  catch loggerError
    lastChanceLog(error, loggerError)

mixinRequest = (error, request) ->
  error.url = request.url if request.url
  error.component = request.component if request.component
  error.action = request.method if request.method
  error.params = request.params if request.params and request.params.length > 0
  error.session = request.session if request.session
  error.stack ?= ''

lastChanceLog = (originalError, errorHandlerError) ->
  # don't use logError because it may be the reason
  # we're in this method
  originalError = JSON.stringify originalError, ['stack']
  errorHandlerError = JSON.stringify errorHandlerError, ['stack']

  timestamp = (new Date).toISOString()
  message = "[#{timestamp}] Unhandled Error in Error Handler: ErrorHandlerError=#{errorHandlerError} Original=#{originalError}"

  console.error message

