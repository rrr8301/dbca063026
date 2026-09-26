FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js versions
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Source nvm and install Node.js 25.6.1 and 24, with yarn for each
RUN bash -c "source $NVM_DIR/nvm.sh && \
    nvm install 25.6.1 && \
    npm install -g yarn && \
    nvm install 24 && \
    npm install -g yarn && \
    nvm alias default 24"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]