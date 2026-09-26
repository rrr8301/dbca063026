FROM ubuntu:22.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.18.0
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs=22.18.0-1nodesource1 && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Set environment variables
ENV FORCE_COLOR=1 \
    DISABLE_V8_COMPILE_CACHE=1 \
    NODE_ENV=test

# Create work directory
WORKDIR /workspace

# Copy entire project directory (including package.json, pnpm-lock.yaml, etc.)
COPY . /workspace/

# Copy run.sh and make it executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]