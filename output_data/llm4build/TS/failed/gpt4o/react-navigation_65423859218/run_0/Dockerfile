# Dockerfile
FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
COPY .nvmrc /tmp/.nvmrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install $(cat /tmp/.nvmrc) \
    && nvm use $(cat /tmp/.nvmrc) \
    && nvm alias default $(cat /tmp/.nvmrc)

# Install Yarn
RUN npm install -g yarn

# Create and set working directory
WORKDIR /app

# Copy repository files
COPY . .

# Install project dependencies
RUN yarn install --immutable

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]