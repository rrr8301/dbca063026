FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Ensure .nvmrc is present and contains a valid Node.js version
RUN if [ ! -f .nvmrc ]; then echo "16" > .nvmrc; fi

# Install Node.js version specified in .nvmrc
RUN bash -c ". $NVM_DIR/nvm.sh && nvm install $(cat .nvmrc) && nvm use $(cat .nvmrc)"

# Install Playwright
RUN bash -c ". $NVM_DIR/nvm.sh && npm install -g playwright"

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]