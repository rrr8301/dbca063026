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
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    nodejs \
    npm \
    yarn \
    redis-server \
    chromium-browser \
    chromedriver \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Remove conflicting packages and install pip packages
RUN apt-get remove -y python3-wheel python3-setuptools || true && \
    python3.11 -m pip install --upgrade pip setuptools wheel

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

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