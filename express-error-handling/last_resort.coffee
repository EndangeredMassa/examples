ERROR_LOG_TIMEOUT = 1000

module.exports = (process) ->
  # If all else fails, make sure we exit the process
  # at some point
  setTimeout (->
    console.error "Exiting after error logging timeout."
    process.exit(2)
  ), ERROR_LOG_TIMEOUT

