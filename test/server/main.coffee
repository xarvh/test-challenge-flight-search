assert = require 'assert'
supertest = require 'supertest'
config = require '../../server/config'

main = require '../../server/main'



dummyLogger =
    info: ->
    error: ->


fakeUrl = 'http://fake-url'


validApiResponse =
    "#{fakeUrl}/airports?q=xy": JSON.stringify ['someAirport']
    "#{fakeUrl}/airlines": JSON.stringify [ { code: 'AR' }, { code: 'EZ' } ]
    "#{fakeUrl}/flight_search/AR?from=NYC&to=MEL&date=2016-11-21": JSON.stringify ['ara', 'arb']
    "#{fakeUrl}/flight_search/EZ?from=NYC&to=MEL&date=2016-11-21": JSON.stringify ['eza', 'ezb']



describe 'app', ->


    config.set 'flightApiUrl', fakeUrl


    mainWithOverloadedApi = (error, statusCode, responseBody) ->
        main.independence 'rebuild',
            config: config
            request:
                get: (url, cb) ->
                    assert validApiResponse[url], "invalid req [#{url}]"
                    setImmediate ->
                        cb error, {statusCode}, responseBody or validApiResponse[url]


    successfulMain = mainWithOverloadedApi null, 200
    failingApiMain = mainWithOverloadedApi null, 400, "The API does not like the specific user"
    failingConnectionMain = mainWithOverloadedApi new Error 'B00M!'


    it 'responds to airports/', (done) ->
        supertest successfulMain dummyLogger
            .get '/airports?q=xy'
            .end (err, res) ->
                assert !err, err
                assert.equal res.statusCode, 200
                assert.deepEqual res.body, ['someAirport']
                done()
        return



    it 'responds to search/', (done) ->
        supertest successfulMain dummyLogger
            .get '/search?from=NYC&to=MEL&date=2016-11-21'
            .end (err, res) ->
                assert !err, err
                assert.equal res.statusCode, 200
                assert.deepEqual res.body, [ 'ara', 'arb', 'eza', 'ezb' ]
                done()
        return


    it 'handles API errors', (done) ->
        supertest failingApiMain dummyLogger
            .get '/search?from=NYC&to=MEL&date=2016-11-21'
            .end (err, res) ->
                assert !err, err
                assert.equal res.statusCode, 500
                assert.equal res.text, 'The API does not like the specific user'
                done()
        return

    it 'handles connection errors', (done) ->
        supertest failingConnectionMain dummyLogger
            .get '/search?from=NYC&to=MEL&date=2016-11-21'
            .end (err, res) ->
                assert !err, err
                assert.equal res.statusCode, 500
                assert.equal res.text, 'B00M!'
                done()
        return

