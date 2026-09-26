FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 and enable corepack
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g corepack && \
    corepack enable && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

ENV GITHUB_TOKEN=$GITHUB_TOKEN
ENV NX_CLOUD_ACCESS_TOKEN=$NX_CLOUD_ACCESS_TOKEN
ENV YARN_ENABLE_HARDENED_MODE=0

# Install dependencies
RUN yarn install --inline-builds && yarn --cwd packages/create-redwood-rsc-app install --inline-builds

# Build the project
RUN yarn build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
