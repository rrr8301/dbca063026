FROM node:22.13.0-alpine

ENV DEBIAN_FRONTEND=noninteractive

RUN apk update && apk add --no-cache \
    python3 \
    make \
    g++ \
    git

WORKDIR /app

COPY repo/ /app/

RUN npm ci

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
