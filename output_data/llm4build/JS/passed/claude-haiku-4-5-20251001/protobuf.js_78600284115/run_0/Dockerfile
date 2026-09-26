FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true \
    NPM_CONFIG_AUDIT=false

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 12 via nvm
ENV NVM_DIR=/opt/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install 12 && \
    nvm alias default 12

# Create non-root user
RUN useradd -m testuser

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Change ownership to testuser
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Activate nvm and install npm 8
RUN . $NVM_DIR/nvm.sh && \
    npm install -g npm@8

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]