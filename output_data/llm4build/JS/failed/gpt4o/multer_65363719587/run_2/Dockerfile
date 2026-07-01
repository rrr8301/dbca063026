FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js 11.15
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Source nvm and install Node.js and npm packages
RUN bash -c "source $NVM_DIR/nvm.sh && \
    nvm install 11.15 && \
    nvm use 11.15 && \
    nvm alias default 11.15 && \
    ln -s $NVM_DIR/versions/node/v11.15/bin/node /usr/local/bin/node && \
    ln -s $NVM_DIR/versions/node/v11.15/bin/npm /usr/local/bin/npm && \
    npm install --save-dev mocha@8.4.0 && \
    npm install"

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]