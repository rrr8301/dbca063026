FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables for CI
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m testuser

# Switch to non-root user
USER testuser
WORKDIR /home/testuser

# Install Rust beta
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain beta
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Install cargo-nextest with --locked
RUN /home/testuser/.cargo/bin/cargo install --locked cargo-nextest

# Configure git
RUN git config --global --add safe.directory '*'

# Copy repository
COPY --chown=testuser:testuser . /home/testuser/workspace
WORKDIR /home/testuser/workspace

# Ensure run.sh is executable
RUN chmod +x /home/testuser/workspace/run.sh

# Ensure cargo environment is sourced
RUN echo 'source $HOME/.cargo/env' >> /home/testuser/.bashrc

# Source the cargo environment in the Dockerfile to ensure it's available
RUN /bin/bash -c "source $HOME/.cargo/env"