const {expect} = require('chai');
const Chance = require('chance');

const {createServer} = require('./server');

describe('tests', () => {
    let server,
        chance;

    beforeEach(() => {
        server = createServer(5555);
        chance = new Chance();
    });

    describe('/', () => {
        let getTime,
            expectedTime;

        beforeEach(() => {
            getTime = Date.prototype.getTime;

            expectedTime = chance.natural();
            Date.prototype.getTime = () => expectedTime;
        });

        afterEach(() => {
            Date.prototype.getTime = getTime;
        });

        it('should respond with a dummy payload', async () => {
            const expectedPayload = {
                message: 'Automate all the things!',
                timestamp: Math.floor(expectedTime / 1000)
            };
            const response = await server.inject('/');
            const actualPayload = JSON.parse(response.payload);

            expect(response.statusCode).to.equal(200);
            expect(expectedPayload).to.deep.equal(actualPayload)
        });
    });

    describe('/healthz', () => {
        it('should respond with a 200', async () => {
            const response = await server.inject('/healthz');

            expect(response.statusCode).to.equal(200);
        });
    });
});