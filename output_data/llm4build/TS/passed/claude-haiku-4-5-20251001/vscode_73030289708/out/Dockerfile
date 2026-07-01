FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    pkg-config \
    xvfb \
    libgtk-3-0 \
    libxkbfile-dev \
    libkrb5-dev \
    libgbm1 \
    rpm \
    bubblewrap \
    socat \
    fontconfig \
    fonts-dejavu \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x (matching .nvmrc requirement)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Setup X server
RUN cp build/azure-pipelines/linux/xvfb.init /etc/init.d/xvfb && \
    chmod +x /etc/init.d/xvfb && \
    update-rc.d xvfb defaults || true

# Set environment variables
ENV VSCODE_QUALITY=oss \
    NPM_ARCH=x64 \
    VSCODE_ARCH=x64 \
    DISPLAY=:10 \
    ELECTRON_SKIP_BINARY_DOWNLOAD=1 \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]