# WebDriver does not return status codes or response headers.
# This module stores those in a special cookie that can be read
# from normal WebDriver methods.

encode = (string) ->
  (new Buffer string).toString('base64')

buildCookie = (headers, statusCode) ->
  encodedData = {headers, statusCode}
  encodedData = JSON.stringify encodedData
  encodedData = encode(encodedData)
  "_testium_=#{encodedData}; path=/"

isSupportedType = (type) ->
  return false unless type?
  return true if type.indexOf('text/html') > -1
  return true if type.indexOf('text/plain') > -1
  false

module.exports = (response) ->
  type = response.headers["content-type"]
  return unless isSupportedType(type)

  if response.headers["Set-Cookie"]
    console.log "Existing Set-Cookie Header!! #{response.headers["Set-Cookie"]}"

  response.headers["Set-Cookie"] = buildCookie(response.headers, response.statusCode)
  console.log "<-- Set-Cookie: " + response.headers["Set-Cookie"]

