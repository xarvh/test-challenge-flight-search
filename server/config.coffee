_ = require 'lodash'
assert = require 'assert'



cfg =
    serverPort: 3000
    flightApiUrl: 'http://node.locomote.com/code-task/'
    flightApiQueryLimit: 4



module.exports = (id) ->
    assert id
    assert cfg[id]

    return cfg[id]



module.exports.set = (key, value) ->
    assert cfg[key]
    assert value
    cfg[key] = value
