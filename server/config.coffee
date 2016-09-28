assert = require 'assert'



cfg =
    serverPort: 3000
    flightApiUrl: 'http://node.locomote.com/code-task/'
    flightApiQueryLimit: 4



module.exports = (id) ->
    assert id
    assert cfg[id]

    return cfg[id]
