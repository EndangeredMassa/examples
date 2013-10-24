createApp = require './app'
uncaughtHandler = require './uncaught_handler'

app = createApp()

process.on 'uncaughtException', (error) ->
  uncaughtHandler(error, app, process)

