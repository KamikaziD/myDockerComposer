FROM node:18-alpine

RUN mkdir -p /app && chown -R node:node /app

ENV PORT=$PORT

WORKDIR /app

#COPY . ./

USER node

RUN npm i express dotenv && npm i -D nodemon ts-node &&\
    npm i -D typescript @types/express @types/node && npm i --save-dev tsc-alias tsconfig-paths &&\
    npm i concurrently --save-dev

COPY --chown=node:node . .

EXPOSE $PORT

#CMD [ "npm", "run", "build" ]
#CMD [ "npm", "run", "dev" ]