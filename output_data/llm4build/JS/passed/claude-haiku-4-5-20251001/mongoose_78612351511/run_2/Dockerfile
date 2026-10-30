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
    FORCE_COLOR=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v20 globally using nvm as root
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    export NVM_DIR=/usr/local/nvm && \
    mkdir -p $NVM_DIR && \
    . $NVM_DIR/nvm.sh && \
    nvm install 20 && \
    nvm use 20 && \
    nvm alias default 20 && \
    ln -s $NVM_DIR/versions/node/v20.*/bin/node /usr/local/bin/node && \
    ln -s $NVM_DIR/versions/node/v20.*/bin/npm /usr/local/bin/npm && \
    ln -s $NVM_DIR/versions/node/v20.*/bin/npx /usr/local/bin/npx

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