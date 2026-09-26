FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install node \
    && nvm use node \
    && npm install -g pnpm

# Set PATH for Node.js and pnpm
ENV PATH="$NVM_DIR/versions/node/$(nvm current)/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install project dependencies
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && pnpm install"

# Install Playwright Chromium
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && pnpm exec playwright install chromium"

# Copy run.sh and set as entrypoint
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]