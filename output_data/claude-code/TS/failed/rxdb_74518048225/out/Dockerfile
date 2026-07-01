FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=24.15.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.15.0
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs=24.15.0-1nodesource1 && \
    npm install -g npm@latest

WORKDIR /app

COPY repo/ /app/

RUN npm install || (sleep 15 && npm install) || (sleep 15 && npm install)

RUN npm run build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
