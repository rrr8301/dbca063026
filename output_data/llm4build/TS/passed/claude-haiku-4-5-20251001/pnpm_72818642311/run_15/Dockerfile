FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    ca-certificates \
    python3 \
    python3-dev \
    libfuse-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.13.0 and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Initialize git repository BEFORE installing dependencies (required for ghooks and other git-dependent tools)
RUN git init && \
    git config user.email "test@example.com" && \
    git config user.name "Test User" && \
    git add . && \
    git commit -m "Initial commit" --no-verify || true

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]