FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 via nvm
ENV NVM_DIR=/opt/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

ENV PATH=$NVM_DIR/versions/node/v20.*/bin:$NVM_DIR/bin:$PATH

RUN . $NVM_DIR/nvm.sh && \
    nvm install 20 && \
    nvm alias default 20 && \
    npm install -g npm@latest

# Install Playwright system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgconf-2-4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxrandr2 \
    libxinerama1 \
    libxi6 \
    libxcursor1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]