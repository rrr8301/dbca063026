FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true \
    NPM_CONFIG_AUDIT=false

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS via nvm
ENV NVM_DIR=/opt/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install --lts && \
    nvm alias default node && \
    ln -s $NVM_DIR/versions/node/*/bin/node /usr/local/bin/node && \
    ln -s $NVM_DIR/versions/node/*/bin/npm /usr/local/bin/npm && \
    ln -s $NVM_DIR/versions/node/*/bin/npx /usr/local/bin/npx

# Create non-root user
RUN useradd -m testuser

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Fix ownership
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]