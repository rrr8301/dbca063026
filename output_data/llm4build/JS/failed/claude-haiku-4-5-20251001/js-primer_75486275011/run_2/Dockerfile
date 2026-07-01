FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 24 via nvm globally
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
    export NVM_DIR=/usr/local/nvm && \
    mkdir -p /usr/local/nvm && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | NVM_DIR=/usr/local/nvm bash && \
    . /usr/local/nvm/nvm.sh && \
    nvm install 24 && \
    nvm alias default 24 && \
    chmod -R 755 /usr/local/nvm && \
    ln -s /usr/local/nvm/versions/node/v24.*/bin/node /usr/local/bin/node && \
    ln -s /usr/local/nvm/versions/node/v24.*/bin/npm /usr/local/bin/npm && \
    ln -s /usr/local/nvm/versions/node/v24.*/bin/npx /usr/local/bin/npx

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser /workspace

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

ENTRYPOINT ["/workspace/run.sh"]