FROM ubuntu:22.04

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
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.14.0 via nvm
ENV NVM_DIR=/opt/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install 22.14.0 && \
    nvm alias default 22.14.0 && \
    nvm use default

# Add nvm to PATH
ENV PATH=$NVM_DIR/versions/node/v22.14.0/bin:$PATH

# Verify Node.js and npm installation
RUN node --version && npm --version

# Install Yarn globally
RUN npm install -g yarn

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make run.sh executable
RUN chmod +x /workspace/run.sh

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user and transfer ownership
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]