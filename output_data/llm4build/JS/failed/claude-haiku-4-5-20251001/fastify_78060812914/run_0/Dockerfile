FROM ubuntu:24.04

# Set timezone and CI environment variables
ENV TZ=America/Los_Angeles \
    CI=true \
    GITHUB_ACTIONS=true \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 26.x from official source
RUN curl -fsSL https://deb.nodesource.com/setup_26.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm installation
RUN node --version && npm --version

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git safe directory to avoid ownership errors
RUN git config --global --add safe.directory '*'

# Create non-root user for test execution
RUN useradd -m -u 1000 testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]