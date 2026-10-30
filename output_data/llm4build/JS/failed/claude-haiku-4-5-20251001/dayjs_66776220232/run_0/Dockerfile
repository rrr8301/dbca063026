FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS via nvm
ENV NVM_DIR=/home/testuser/.nvm
ENV NODE_VERSION=20
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

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

# Ensure nvm is available in the shell
ENV PATH=$NVM_DIR/versions/node/v${NODE_VERSION}.*/bin:$PATH

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]