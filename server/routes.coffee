_ = require 'lodash'
assert = require 'assert'
async = require 'async'
request = require 'request'
{resolve} = require 'url'



module.exports = ({log, config}) ->
    assert log
    assert config



    apiUrl = (apiEndpoint) ->
        return resolve (config 'flightApiUrl'), apiEndpoint



    requestJson = (url) -> (cb) ->
        async.waterfall [

            (cb) ->
                log.info "GET #{url}..."
                request.get url, cb
        ,

            (response, body, cb) ->
                if response.statusCode >= 400
                    err = body
                    log.error "GET #{url} #{response.statusCode}: #{err}"
                else
                    log.info "GET #{url} #{response.statusCode}"

                cb err, body
        ,

            (body, cb) ->
                result = try JSON.parse body catch err
                cb err, result
        ], cb



    simpleRequest = (apiEndpoint) -> (req, res, next) ->
        request
            .get apiUrl apiEndpoint
            .pipe res



    search = (req, res, next) ->

        apiQueryLimit = config 'flightApiQueryLimit'

        # TODO actually get query
        query = 'date=2016-09-30&from=SYD&to=JFK'

        async.waterfall [

            requestJson apiUrl 'airlines'
        ,

            (airlines, cb) ->
                async.mapLimit airlines, apiQueryLimit, (airline, cb) ->
                    (requestJson apiUrl "flight_search/#{airline.code}?#{query}")(cb)
                , cb
        ,

            (allSearchResults, cb) ->
                res.send allSearchResults

        ], next


    return {
        simpleRequest
        search
    }
