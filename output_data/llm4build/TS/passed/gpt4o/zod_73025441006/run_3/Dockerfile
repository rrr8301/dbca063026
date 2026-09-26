# Dockerfile
FROM node:lts

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Set the SHELL environment variable to bash
ENV SHELL=/bin/bash

# Set up pnpm global bin directory and ensure it's in the PATH
RUN pnpm setup && \
    source /root/.bashrc && \
    echo 'export PATH="$PNPM_HOME:$PATH"' >> /root/.bashrc

# Create and set work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install TypeScript globally
RUN source /root/.bashrc && pnpm add typescript@5.5 -g

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]