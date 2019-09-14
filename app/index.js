const {createServer} = require('./server');

(async () => {
    const port = process.env.APP_PORT || 5555;
    const server = createServer(port);

    ['SIGINT', 'SIGTERM'].forEach((signal) => {
        process.on(signal, async () => {
            await server.stop();
        });
    });

    await server.start();
    console.log(`Listening on port ${port}`)
})();
