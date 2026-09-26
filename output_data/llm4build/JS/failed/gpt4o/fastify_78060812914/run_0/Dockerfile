FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install 20 && nvm install 22 && nvm install 24 && nvm install 26

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Add non-root user
RUN useradd -m -u 1000 testuser && chown -R testuser /workspace
USER testuser

# Copy run.sh and set as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh
ENTRYPOINT ["/workspace/run.sh"]