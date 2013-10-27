http = require('http')
url = require('url')
concat = require('concat-stream')

buildRemoteRequestOptions = (request, toPort) ->
  uri = url.parse(request.url)
  opt =
    port: toPort
    path: uri.path
    method: request.method
    headers: request.headers

  opt.headers['connection'] = 'keep-alive'
  opt.headers['cache-control'] = 'no-store'
  delete opt.headers['if-none-match']
  delete opt.headers['if-modified-since']
  opt

openRequests = []
newPage = true
newPageOptions = {}
markNewPage = (body, response) ->
  newPage = true
  newPageOptions = body || {}
  console.log "\n[System] Marking new page request with options: #{JSON.stringify newPageOptions}"
  for request in openRequests
    console.log '[System] Aborting request for: ' + request.path
    request.abort()
  openRequests = []
  response.end()

markRequestClosed = (targetRequest) ->
  openRequests = openRequests.filter (request) ->
    request != targetRequest

commandError = (url, response) ->
  console.log "[System] Unknown command: #{url}"
  response.statusCode = 500
  response.end()

proxyCommand = (url, body, response) ->
  switch url
    when '/new-page' then markNewPage(body, response)
    else commandError(url, response)

modifyRequest = (request, options) ->
  return unless options.headers?

  for header, value of options.headers
    request.headers[header] = value

proxyRequest = (request, response, modifyResponse, toPort) ->
  console.log "--> #{request.method} #{request.url}"

  remoteRequestOptions = buildRemoteRequestOptions(request, toPort)
  console.log "    #{JSON.stringify remoteRequestOptions}"

  if newPage && request.url.indexOf('/favicon.ico') != 0
    modifyRequest(remoteRequestOptions, newPageOptions)

  remoteRequest = http.request remoteRequestOptions, (remoteResponse) ->
    markRequestClosed(remoteRequest)

    if newPage && request.url.indexOf('/favicon.ico') != 0
      newPage = false
      modifyResponse(remoteResponse)

    response.writeHead remoteResponse.statusCode, remoteResponse.headers
    remoteResponse.on 'end', ->
      console.log "<-- #{response.statusCode} #{request.url}"

    remoteResponse.pipe response

  remoteRequest.on 'error', (error) ->
    response.statusCode = 500
    console.log JSON.stringify error, ['message', 'stack'], 2
    console.log '<-- ' + response.statusCode + ' ' + request.url
    markRequestClosed(remoteRequest)
    response.end()

  openRequests.push remoteRequest

  request.pipe remoteRequest
  request.on 'end', ->
    remoteRequest.end()

server = null
commandServer = null
module.exports = (fromPort, toPort, commandPort, modifyResponse) ->
  server = http.createServer (request, response) ->
    proxyRequest(request, response, modifyResponse, toPort)
  server.listen fromPort
  console.log "Listening on port #{fromPort} and proxying to #{toPort}."

  commandServer = http.createServer (request, response) ->
    request.pipe concat (body) ->
      options = JSON.parse(body.toString())
      proxyCommand(request.url, options, response)
  commandServer.listen commandPort
  console.log "Listening for commands on port #{commandPort}."

