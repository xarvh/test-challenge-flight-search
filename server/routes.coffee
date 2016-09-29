_ = require 'lodash'
assert = require 'assert'
async = require 'async'
request = require 'request'
{resolve} = require 'url'



module.exports = ({log, config}) ->
    assert log
    assert config



    apiUrl = (apiEndpoint, queryHash) ->
        base = resolve (config 'flightApiUrl'), apiEndpoint
        query = if queryHash then '?' + _.map(queryHash, (v, k) -> "#{k}=#{v}").join '&' else ''
        return base + query



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
        async.waterfall [

            requestJson apiUrl apiEndpoint, req.query
        ,
            (result, cb) ->
                res.send result

        ], next



    search = (req, res, next) ->

        apiQueryLimit = config 'flightApiQueryLimit'

        async.waterfall [

            requestJson apiUrl 'airlines'
        ,

            (airlines, cb) ->
                async.mapLimit airlines, apiQueryLimit, (airline, cb) ->
                    (requestJson apiUrl "flight_search/#{airline.code}", req.query)(cb)
                , cb
        ,

            (allSearchResults, cb) ->
#                fs = require 'fs'
#                fs.writeFileSync (apiUrl "flight_search/", req.query).replace(/[/:?&=]/g, '_'), (JSON.stringify allSearchResults)
                res.send allSearchResults

        ], next


    return {
        simpleRequest
        search
    }
