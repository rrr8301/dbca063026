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

# Install build tools and dependencies (including ca-certificates for curl)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m testuser

# Install Node.js LTS via nvm as testuser
ENV NVM_DIR=/home/testuser/.nvm
ENV NODE_VERSION=20
USER testuser
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Set working directory
WORKDIR /workspace

# Copy repository
COPY --chown=testuser:testuser . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Ensure nvm is available in the shell
ENV PATH=$NVM_DIR/versions/node/v${NODE_VERSION}.*/bin:$PATH

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]