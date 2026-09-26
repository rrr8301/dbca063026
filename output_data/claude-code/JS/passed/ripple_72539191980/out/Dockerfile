FROM node:24.0.0-alpine

ENV DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache \
    bash \
    git \
    python3 \
    make \
    g++ \
    gcc \
    perl

RUN npm install -g pnpm@10.18.2

WORKDIR /app

COPY repo/ /app/

RUN pnpm install --prod false --frozen-lockfile

RUN cd /app/packages/cli && pnpm build

RUN cd /app/packages/eslint-parser && pnpm build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
