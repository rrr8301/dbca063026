FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.6.0
RUN curl -fsSL https://nodejs.org/dist/v24.6.0/node-v24.6.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

COPY repo/ /app/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build LangChain Core
RUN pnpm build --filter @langchain/core

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
