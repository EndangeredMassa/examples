express = require 'express'
http = require 'http'
expressLogger = require './express_logger'
Domain = require 'domain'
lastResortExit = require './last_resort'

module.exports = ->
  app = express()

  app.get '/', (req, res) ->
    res.send('hello world')

  app.get '/error', (request, response) ->
    throw new Error('you went to /error, silly!')

  app.get '/asyncerror', (request, response) ->
    setTimeout (->
      throw new Error('you went to /asyncerror, silly!')
    ), 100

  app.get '/domainerror', (request, response) ->
    domain = Domain.create()
    domain.on 'error', (error) ->
      lastResortExit(process)
      expressLogger error, request, ->
        process.exit(150)

    domain.run ->
      setTimeout (->
        throw new Error('you went to /domainerror, silly!')
      ), 100

  app.use (error, request, response, next) ->
    expressLogger(error, request, next)

    # render some error page to the `response`
    response.status = 500
    response.end()

  server = http.createServer app
  server.listen(5555)
  console.log 'listening on localhost:5555'

  server

