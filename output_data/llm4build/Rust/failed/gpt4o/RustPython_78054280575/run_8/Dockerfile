FROM ubuntu:22.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    /root/.cargo/bin/rustup target add x86_64-unknown-linux-gnu && \
    echo 'source $HOME/.cargo/env' >> /root/.bashrc

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    mkdir -p /home/testuser/.cargo && \
    chown -R testuser:testuser /workspace /home/testuser/.cargo

# Copy Rust environment to the new user
RUN cp -r /root/.cargo /home/testuser/.cargo && \
    chown -R testuser:testuser /home/testuser/.cargo

# Ensure the Rust environment is sourced for the new user
RUN echo 'source /home/testuser/.cargo/env' >> /home/testuser/.bashrc

USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]