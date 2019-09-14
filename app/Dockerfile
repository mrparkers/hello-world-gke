FROM node:12.10.0-alpine as build

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .

RUN yarn

COPY test.js .
COPY server.js .
COPY index.js .

RUN yarn test

FROM node:12.10.0-alpine

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/package.json .
COPY --from=build /usr/src/app/yarn.lock .

RUN yarn --production

COPY --from=build /usr/src/app/test.js .
COPY --from=build /usr/src/app/server.js .
COPY --from=build /usr/src/app/index.js .

ENTRYPOINT ["node", "index.js"]
