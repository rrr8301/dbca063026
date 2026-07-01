FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install curl and build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Enable corepack
RUN corepack enable

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install pnpm dependencies and build deps
RUN make install

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
