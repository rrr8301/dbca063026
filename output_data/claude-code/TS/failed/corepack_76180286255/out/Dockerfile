FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV YARN_ENABLE_GLOBAL_CACHE=false
ENV NOCK_ENV=replay

RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN corepack yarn install --immutable
RUN corepack yarn build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
