# Dockerfile
FROM ubuntu:20.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    lsb-release \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add NodeSource GPG key and install Node.js 14
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -

# Install Node.js
RUN apt-get update && apt-get install -y nodejs

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install npm dependencies
RUN npm ci

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]