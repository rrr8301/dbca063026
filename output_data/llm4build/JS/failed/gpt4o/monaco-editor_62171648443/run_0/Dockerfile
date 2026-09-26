FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libx11-dev \
    libx11-xcb-dev \
    libxkbfile-dev \
    libnotify-bin \
    libkrb5-dev \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR
ENV NODE_VERSION=$(cat /path/to/repo/.nvmrc)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Node.js dependencies
RUN . $NVM_DIR/nvm.sh && npm ci

# Copy run.sh and set as entrypoint
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]