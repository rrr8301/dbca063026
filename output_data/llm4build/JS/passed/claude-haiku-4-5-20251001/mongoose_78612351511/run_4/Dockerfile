FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true \
    MONGOMS_VERSION=6.0.15 \
    MONGOMS_PREFER_GLOBAL_PATH=1 \
    FORCE_COLOR=true \
    NVM_DIR=/root/.nvm

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v20 using nvm as root
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install 20 && \
    nvm use 20 && \
    nvm alias default 20

# Create symlinks for node, npm, and npx in /usr/local/bin
RUN . $NVM_DIR/nvm.sh && \
    NODE_PATH=$(which node) && \
    NPM_PATH=$(which npm) && \
    NPX_PATH=$(which npx) && \
    ln -sf $NODE_PATH /usr/local/bin/node && \
    ln -sf $NPM_PATH /usr/local/bin/npm && \
    ln -sf $NPX_PATH /usr/local/bin/npx

# Verify symlinks work
RUN /usr/local/bin/node --version && \
    /usr/local/bin/npm --version

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user and grant access to workspace
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]