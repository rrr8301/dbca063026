FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV YARN_ENABLE_GLOBAL_CACHE=false
ENV NOCK_ENV=replay

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN npm install -g corepack && \
    corepack yarn install --immutable

RUN corepack yarn build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
