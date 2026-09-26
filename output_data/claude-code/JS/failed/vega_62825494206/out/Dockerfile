FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update apt and install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    libxml2-utils \
    python3 \
    make \
    g++ \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install npm dependencies
RUN npm ci

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
