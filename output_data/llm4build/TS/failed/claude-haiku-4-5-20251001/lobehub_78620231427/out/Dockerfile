FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Install Node.js 24.11.1
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@latest

# Install Bun 1.3.2 as root first
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.2"

# Create non-root user
RUN useradd -m testuser

# Copy Bun installation to a location accessible by all users
RUN cp -r /root/.bun /usr/local/bun && \
    chmod -R 755 /usr/local/bun && \
    ln -sf /usr/local/bun/bin/bun /usr/local/bin/bun

# Transfer workspace ownership
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Verify bun is accessible
RUN bun --version

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]