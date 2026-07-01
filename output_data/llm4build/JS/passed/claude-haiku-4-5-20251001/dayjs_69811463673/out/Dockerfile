FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Install Node.js LTS via nvm
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | NVM_DIR=$NVM_DIR bash
RUN . $NVM_DIR/nvm.sh && nvm install lts/* && nvm alias default lts/*

# Install npm dependencies (as root before switching user)
RUN . $NVM_DIR/nvm.sh && npm install

# Create non-root user and transfer ownership
RUN useradd -m testuser
RUN chown -R testuser:testuser /workspace $NVM_DIR

# Switch to non-root user
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]