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
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory to avoid ownership errors
RUN git config --global --add safe.directory '*'

# Copy and set run script as entrypoint (BEFORE switching user)
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create non-root user for test execution (use UID 1001 to avoid conflicts)
RUN useradd -m -u 1001 testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

ENTRYPOINT ["/workspace/run.sh"]