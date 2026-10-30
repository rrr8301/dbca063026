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
ENV FORCE_COLOR=true
ENV ASTRO_TELEMETRY_DISABLED=true
ENV NODE_OPTIONS=--max-old-space-size=6144
ENV NODE_VERSION=22

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 via nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . $NVM_DIR/nvm.sh && nvm install 22 && nvm alias default 22

# Add Node.js to PATH
ENV PATH=$NVM_DIR/versions/node/v22.*/bin:$PATH

# Install pnpm globally
RUN npm install -g pnpm

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]