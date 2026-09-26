FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Create non-root user
RUN useradd -m testuser
USER testuser
WORKDIR /home/testuser

# Install nvm and Node.js as non-root user
ENV NVM_DIR=/home/testuser/.nvm
RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN bash -c ". $NVM_DIR/nvm.sh && nvm install 22 && nvm use 22"

# Create work directory
WORKDIR /home/testuser/workspace

# Copy repository
COPY --chown=testuser:testuser . /home/testuser/workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Node.js dependencies
RUN bash -c ". $NVM_DIR/nvm.sh && nvm use 22 && npm ci"

# Build client dependencies
RUN bash -c ". $NVM_DIR/nvm.sh && nvm use 22 && npm run build:client"

# Entrypoint
ENTRYPOINT ["/bin/bash", "/home/testuser/workspace/run.sh"]