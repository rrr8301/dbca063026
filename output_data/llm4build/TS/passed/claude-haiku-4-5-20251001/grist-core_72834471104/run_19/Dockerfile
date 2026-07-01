FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NODE_VERSION=22.x

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    python3-pip \
    nodejs \
    npm \
    yarn \
    redis-server \
    chromium-browser \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA and install Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel with break-system-packages flag
# Use --ignore-installed to skip uninstalling system pip
RUN python3.11 -m pip install --upgrade --no-cache-dir --break-system-packages --ignore-installed pip setuptools wheel

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Create app directory
WORKDIR /app

# Copy project files
COPY . .

# Install Node.js dependencies
RUN yarn install

# Install Python dependencies
RUN yarn run install:python || true

# Expose ports
EXPOSE 3000 6379 9000

# Default command
CMD ["/bin/bash"]