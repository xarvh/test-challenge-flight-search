express = require 'express'

config = require './config'
routes = require './routes'



module.exports = main = ->

    app = express()

    app.get '/airlines', routes.simpleRequest 'airlines'
    app.get '/airports', routes.simpleRequest 'airports'
    app.get '/search', routes.search

    app.use '/static', express.static 'public-generated'
    app.use '/static', express.static 'public-committed'

    port = config 'serverPort'
    app.listen port, () ->
      console.info "Listening on port #{port}."



if require.main == module
    main()
