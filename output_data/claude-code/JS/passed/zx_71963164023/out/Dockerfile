FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=3
ENV npm_config_audit=false
ENV npm_config_fund=false
ENV npm_config_save=false
ENV npm_config_package_lock=false

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24 from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js installation
RUN node --version && npm --version

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install dependencies
RUN npm ci

# Build the project
RUN npm run build

# Copy and setup run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
