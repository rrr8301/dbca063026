FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    build-essential \
    python3 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install project dependencies
RUN npm install

# Create separate require instance for testing
RUN npm run create-separate-require-instance

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set environment variables for MongoDB Memory Server
ENV MONGOMS_VERSION=6.0.15
ENV MONGOMS_PREFER_GLOBAL_PATH=1
ENV FORCE_COLOR=true

ENTRYPOINT ["/run.sh"]
