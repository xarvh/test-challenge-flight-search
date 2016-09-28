express = require 'express'
path = require 'path'

config = require './config'
routesFactory = require './routes'



module.exports = main = ->

    app = express()

    routes = routesFactory {config, log: console}
    app.get '/airlines', routes.simpleRequest 'airlines'
    app.get '/airports', routes.simpleRequest 'airports'
    app.get '/search', routes.search

    app.get '/', (req, res) ->
        res.sendFile path.join process.cwd(), 'public-committed/index.html'

    app.use '/static', express.static 'public-generated'
    app.use '/static', express.static 'public-committed'


    # TODO: add error middleware


    port = config 'serverPort'
    app.listen port, () ->
      console.info "Listening on port #{port}."



if require.main == module
    main()
