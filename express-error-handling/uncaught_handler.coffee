logError = require './log_error'
expressLogger = require './express_logger'
lastResortExit = require './last_resort'

module.exports = (error, server, process) ->
  lastResortExit(process)
  closeServer(server)

  thirdPartyLog error, -> process.exit(1)

serverRunning = (server) ->
  !!server.address()

closeServer = (server) ->
  # closing a server makes it stop accepting requests
  if serverRunning(server)
    server.close()

thirdPartyLog = (error, callback) ->
  expressLogger error, null, callback

