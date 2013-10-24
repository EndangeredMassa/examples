var ERROR_LOG_TIMEOUT = 1e3;

module.exports = function (process) {
  setTimeout(function () {
    console.error('Exiting after error logging timeout.');
    process.exit(2);
  }, ERROR_LOG_TIMEOUT);
};

