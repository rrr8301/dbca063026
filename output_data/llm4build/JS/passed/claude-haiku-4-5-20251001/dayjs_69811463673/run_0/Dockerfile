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
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN . $NVM_DIR/nvm.sh && nvm install lts/* && nvm alias default lts/*

# Create non-root user and transfer ownership
RUN useradd -m testuser
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set up environment for non-root user
ENV PATH=$NVM_DIR/versions/node/$(node -v | cut -d'v' -f2)/bin:$PATH

# Install npm dependencies
RUN npm install

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]