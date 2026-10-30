FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS (20.x)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

# Install corepack and enable pnpm
RUN npm i -g --force corepack && corepack enable

# Install dependencies
RUN pnpm install
RUN pnpm add -D tsx

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Use tsx/esm for loading TypeScript files
ENV NODE_OPTIONS="--import=tsx/esm"

ENTRYPOINT ["/run.sh"]
