proxy = require './proxy'
webdriverWorkaround = require './webdriver_workaround'

getPortParam = ->
  parseInt(process.argv[2], 10)

toPort = getPortParam()
fromPort = 4445
commandPort = 4446

proxy fromPort, toPort, commandPort, webdriverWorkaround

