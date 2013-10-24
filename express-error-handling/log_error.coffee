require 'longjohn'
prettyjson = require('prettyjson')

formatJson = (object) ->
  # adds 4 spaces in front of each line
  json = prettyjson.render(object)
  json = json.split('\n').join('\n    ')
  "    #{json}"

playNiceError = (error) ->
  # remove longjohn properties that break prettyjson
  delete error.__cached_trace__
  delete error.__previous__

  # remove domain properties
  # that we probably don't care about
  delete error.domain

serializeError = (error) ->
  playNiceError(error)

  metadata = formatJson error
  # stack must be called after prettyjson
  # something about this causes future
  # JSON.stringify calls to come up empty
  stack = error.stack.trim()

  message = "#{stack}\n"
  message += "  Metadata:\n#{metadata}" if metadata.trim() != ''
  message

module.exports = (error) ->
  console.error serializeError(error)

