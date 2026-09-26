FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm 10.6.1
RUN npm install -g pnpm@10.6.1

WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install dependencies
RUN cd /app/libraries/typescript && pnpm install --no-frozen-lockfile

# Build packages
RUN cd /app/libraries/typescript && pnpm build

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
