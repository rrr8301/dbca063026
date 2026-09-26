FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=true
ENV ASTRO_TELEMETRY_DISABLED=true
ENV NODE_OPTIONS=--max-old-space-size=6144
ENV TURBO_LOG_ORDER=stream

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@latest

# Configure git
RUN git config --global core.autocrlf false

# Set working directory
WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install dependencies
RUN pnpm install

# Build packages
RUN pnpm run build

# Copy test runner script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
