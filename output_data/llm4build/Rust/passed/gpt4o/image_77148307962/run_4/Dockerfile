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

# Install Rust toolchain for the non-root user
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Copy repository
COPY --chown=testuser:testuser . .

# Configure git
RUN git config --global --add safe.directory '*'

# Ensure Rust environment is set up for the user
RUN /bin/bash -c "source /home/testuser/.cargo/env && rustup default nightly"

# Set work directory
WORKDIR /home/testuser/workspace

# Ensure the Rust environment is sourced in the shell
RUN echo 'source /home/testuser/.cargo/env' >> /home/testuser/.bashrc

# Make run.sh executable
RUN chmod +x /home/testuser/run.sh