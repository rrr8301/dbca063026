FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust for root user
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Ensure Rust environment is available
RUN rustc --version

# Install mdBook
RUN cargo install mdbook --version 0.5.2

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Set up the environment for the root user
RUN echo 'source $HOME/.cargo/env' >> /root/.bashrc

# Ensure the Rust environment is sourced
RUN /bin/bash -c "source $HOME/.cargo/env"

# Make run.sh executable
RUN chmod +x /workspace/run.sh

# Set the entrypoint to run.sh
ENTRYPOINT ["/workspace/run.sh"]