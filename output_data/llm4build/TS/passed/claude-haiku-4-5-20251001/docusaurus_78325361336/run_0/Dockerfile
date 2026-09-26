FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 26
RUN curl -fsSL https://deb.nodesource.com/setup_26.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm installation
RUN node --version && npm --version

# Install yarn globally
RUN npm install -g yarn

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]