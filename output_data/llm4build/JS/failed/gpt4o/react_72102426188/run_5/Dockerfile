FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables for CI
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN bash -c ". $NVM_DIR/nvm.sh && nvm install --lts && nvm use --lts"

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser:testuser /workspace

# Copy the repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install yarn globally as root before switching to testuser
RUN bash -c ". $NVM_DIR/nvm.sh && npm install -g yarn"

# Ensure nvm is accessible to testuser
RUN mkdir -p /home/testuser/.nvm && cp -r /root/.nvm/* /home/testuser/.nvm/ && chown -R testuser:testuser /home/testuser/.nvm
ENV NVM_DIR=/home/testuser/.nvm

# Switch to testuser
USER testuser

# Ensure testuser has permissions to the workspace
RUN chown -R testuser:testuser /workspace

# Install project dependencies
RUN bash -c ". $NVM_DIR/nvm.sh && yarn install"

# Entry point
CMD ["/bin/bash", "/workspace/run.sh"]