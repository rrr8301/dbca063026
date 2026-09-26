FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@10.33.2

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install @antfu/ni
RUN npm i -g @antfu/ni

# Install project dependencies
RUN nci

# Install Playwright browsers
RUN pnpm exec playwright install --with-deps

# Build the project
RUN nr build

# Typecheck
RUN nr typecheck

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
