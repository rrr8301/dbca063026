FROM node:18-alpine

ENV DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache bash git python3 make g++

WORKDIR /app

COPY repo/ /app/

RUN npm ci

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
