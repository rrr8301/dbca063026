FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=24.13.0
ENV PNPM_VERSION=10.28.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    redis-server \
    mysql-server \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@${PNPM_VERSION}

# Set up MySQL
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# Set up Redis
RUN mkdir -p /var/run/redis && \
    chown -R redis:redis /var/run/redis

WORKDIR /app

# Copy the repo
COPY repo/ /app/

# Install project dependencies
RUN pnpm install

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
