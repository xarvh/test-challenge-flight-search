express = require 'express'
path = require 'path'

config = require './config'
routesFactory = require './routes'



module.exports = main = (log) ->

    app = express()

    routes = routesFactory {config, log}
    app.get '/airlines', routes.simpleRequest 'airlines'
    app.get '/airports', routes.simpleRequest 'airports'
    app.get '/search', routes.search

    app.get '/', (req, res) ->
        res.sendFile path.join process.cwd(), 'public-committed/index.html'

    app.use '/static', express.static 'public-generated'
    app.use '/static', express.static 'public-committed'

    app.use (err, req, res, next) ->
        log.error err.stack
        res.status(500).send(err.message)

    return app



if require.main == module
    app = main console

    port = config 'serverPort'
    app.listen port, () ->
      console.info "Listening on port #{port}."
