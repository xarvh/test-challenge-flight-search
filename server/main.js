const express = require('express');

const config = require('./config');
const routes = require('./routes');


module.exports = main;
if (require.main === module) {
    main();
}


function main() {

    const app = express();

    app.get('/airlines', routes.simpleRequest('airlines'));
    app.get('/airports', routes.simpleRequest('airports'));
    app.get('/search', routes.search);

    app.use('/static', express.static('public-generated'));
    app.use('/static', express.static('public-committed'));

    const port = config('serverPort');
    app.listen(port, function () {
      console.info(`Listening on port ${port}.`);
    });
}
