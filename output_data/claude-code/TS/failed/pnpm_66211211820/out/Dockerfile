FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including Node.js
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    python3 \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 using nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    export NVM_DIR="/root/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install 22

# Set up shell profile to have nvm available
RUN echo 'export NVM_DIR="/root/.nvm"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc

# Configure git (required by pnpm test suite)
RUN git config --global core.autocrlf false && \
    git config --global user.name "test-user" && \
    git config --global user.email "test@example.com"

WORKDIR /app

# Copy the repo
COPY repo/ /app/

# Install pnpm using npm (simpler than standalone)
RUN npm install -g pnpm@11

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/bin/bash", "-c", "source /root/.bashrc && /run.sh"]
