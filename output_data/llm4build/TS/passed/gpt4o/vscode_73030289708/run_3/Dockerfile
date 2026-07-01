FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    pkg-config \
    xvfb \
    libgtk-3-0 \
    libxkbfile-dev \
    libkrb5-dev \
    libgbm1 \
    rpm \
    bubblewrap \
    socat \
    git \
    curl \
    wget \
    build-essential \  # Added to provide make and other build tools
    && rm -rf /var/lib/apt/lists/*

# Install Node.js using nvm
COPY .nvmrc /tmp/.nvmrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install $(cat /tmp/.nvmrc) \
    && nvm use $(cat /tmp/.nvmrc) \
    && nvm alias default $(cat /tmp/.nvmrc) \
    && echo "export NODE_VERSION=$(cat /tmp/.nvmrc)" >> /root/.bashrc

# Ensure Node.js and npm are available in the PATH
ENV NVM_DIR="/root/.nvm"
RUN . /root/.bashrc && \
    export NODE_VERSION=$(cat /tmp/.nvmrc) && \
    echo "export PATH=\"$NVM_DIR/versions/node/v$NODE_VERSION/bin:\$PATH\"" >> /root/.bashrc

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Node.js dependencies
RUN . /root/.bashrc && npm ci

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]