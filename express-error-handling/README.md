# express-error-handling

Example for blog post:
[Handling Errors in Node.js](http://massalabs.com/dev/2013/10/17/handling-errors-in-nodejs.html)

## run

`node index.js` or `coffee index.coffee`

Then navigate to:

- [/error](http://localhost:5555/error) throws an error that is caught by the express middleware and delgated to express_logger.coffee
- [/asyncerror](http://localhost:5555/asyncerror) throws an error from the event loop (via process uncaughtException) and is delegated to uncaught_handler.coffee
- [/domainerror](http://localhost:5555/domainerror) throws an error from the event loop, but bound to a domain, and is delegated to express_logger.coffee

