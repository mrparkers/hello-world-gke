const {Server} = require('hapi');

const createServer = (port) => {
    const server = new Server({
        host: '0.0.0.0',
        port
    });

    server.route({
        path: '/',
        method: 'GET',
        handler: () => ({
            message: 'Automate all the things!',
            timestamp: Math.floor(new Date().getTime() / 1000)
        })
    });

    server.route({
        path: '/healthz',
        method: 'GET',
        handler: () => 'ok'
    });

    return server;
};

module.exports = {
    createServer
};
