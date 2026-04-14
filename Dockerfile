FROM node:20-alpine

WORKDIR /app
RUN chown node:node /app

COPY --chown=node:node package*.json ./

USER node

RUN npm ci --only=production

COPY --chown=node:node . .

CMD ["node", "index.js"]

# test
