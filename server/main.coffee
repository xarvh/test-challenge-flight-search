express = require 'express'

config = require './config'
routesFactory = require './routes'



module.exports = main = ->

    app = express()

    routes = routesFactory {config, log: console}
    app.get '/airlines', routes.simpleRequest 'airlines'
    app.get '/airports', routes.simpleRequest 'airports'
    app.get '/search', routes.search

    app.use '/static', express.static 'public-generated'
    app.use '/static', express.static 'public-committed'


    # TODO: add error middleware


    port = config 'serverPort'
    app.listen port, () ->
      console.info "Listening on port #{port}."



if require.main == module
    main()
