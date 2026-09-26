FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages with retry mechanism
RUN apt-get update || (sleep 30 && apt-get update) \
    && apt-get install -y --no-install-recommends \
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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR
COPY .nvmrc /tmp/.nvmrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $(cat /tmp/.nvmrc) \
    && nvm use $(cat /tmp/.nvmrc) \
    && nvm alias default $(cat /tmp/.nvmrc)

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