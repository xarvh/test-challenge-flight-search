const _ = require('lodash');
const async = require('async');
const request = require('request');
const url = require('url');

const config = require('./config');



function apiUrl(apiEndpoint) {
    return url.resolve(config('flightApiUrl'), apiEndpoint);
}



module.exports.simpleRequest = (apiEndpoint) => function simpleRequest(req, res, next) {
    request
        .get(apiUrl(apiEndpoint))
        .pipe(res);
};



module.exports.search = function search(req, res, next) {
    const apiQueryLimit = config('apiQueryLimit');

    const query = '';

    async.waterfall([

        function (cb) {
           request.get(apiUrl('airlines'), cb);
        },

        function (response, body, cb) {
            // TODO use actual result
           cb(null, ['MU', 'EK']),
        },

        function (airlineCodes, cb) =>
            async.eachLimit(airlineCodes, apiQueryLimit, function requestAirlineFlights(airlineCode, cb) {
                request.get(apiUrl(`flight_search/${airlineCode}?${query}`), cb);
            }, cb);

        (stuff, cb) =>
            console.log('---------\n', stuff, '---------\n');

    ]);




};
