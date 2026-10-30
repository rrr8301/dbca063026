FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 via nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

ENV NVM_DIR=/root/.nvm
ENV PATH=$NVM_DIR/versions/node/v22.22.3/bin:$PATH

RUN . $NVM_DIR/nvm.sh && nvm install 22 && nvm use 22 && nvm alias default 22

# Enable Corepack and prepare pnpm
RUN . $NVM_DIR/nvm.sh && corepack enable && corepack prepare pnpm@10.33.0 --activate

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Copy and set run.sh as entrypoint with executable permissions
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]