const cfg = {

    serverPort: 3000,

    flightApiUrl: 'http://node.locomote.com/code-task/',

};



const assert = require('assert');

module.exports = function config(id) {
    assert(id);
    assert(cfg[id]);

    return cfg[id];
};
