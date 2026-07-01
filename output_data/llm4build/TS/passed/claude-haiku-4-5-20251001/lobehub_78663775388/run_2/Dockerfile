FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    python3 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.11.1
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs=24.11.1-1nodesource1 && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@latest

# Install Bun 1.3.2 globally
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.2"
ENV PATH="/root/.bun/bin:$PATH"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user and transfer ownership
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace && \
    mkdir -p /home/testuser/.bun && \
    cp -r /root/.bun/* /home/testuser/.bun/ && \
    chown -R testuser:testuser /home/testuser/.bun

# Switch to non-root user
USER testuser

# Set bun path for testuser
ENV PATH="/home/testuser/.bun/bin:$PATH"

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]