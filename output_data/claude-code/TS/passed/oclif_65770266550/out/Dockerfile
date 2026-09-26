FROM node:20-alpine

ENV DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache \
    git \
    bash \
    curl

WORKDIR /app

COPY repo/ /app/

RUN yarn install --frozen-lockfile && \
    yarn build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
