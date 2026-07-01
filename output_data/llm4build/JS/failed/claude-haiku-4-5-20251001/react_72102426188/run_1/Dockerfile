FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

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
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Fix permissions for all shell scripts recursively
RUN find . -type f -name "*.sh" -exec chmod +x {} \;

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Read Node version from .nvmrc and install Node.js
RUN NODE_VERSION=$(cat .nvmrc | tr -d 'v\n') && \
    curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz -o node.tar.xz && \
    tar -xf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz && \
    npm install -g yarn

# Create non-root user
RUN useradd -m testuser

# Transfer workspace ownership to non-root user
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]