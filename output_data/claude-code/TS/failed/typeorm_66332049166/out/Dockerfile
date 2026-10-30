FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=24
ENV PNPM_VERSION=10.33.4

RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js from NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@${PNPM_VERSION}

# Install MySQL 5.7
RUN apt-get update && apt-get install -y \
    mysql-server-5.7 \
    && rm -rf /var/lib/apt/lists/*

# Install MariaDB 10.11
RUN apt-get update && apt-get install -y \
    mariadb-server-10.11 \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Copy the repo
COPY repo/ /app/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Compile TypeScript
RUN pnpm run compile

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
