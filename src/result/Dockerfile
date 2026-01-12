FROM node:18-slim

RUN apt-get update && apt-get install -y --no-install-recommends curl=7.88.1-10+deb12u14 tini=0.19.0-1+b3 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && npm cache clean --force && mv /usr/local/app/node_modules /node_modules

COPY . .

ENV PORT=8080
EXPOSE 8080

USER app

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
