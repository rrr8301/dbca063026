FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    libdbus-1-dev \
    gnome-keyring \
    libxcb1-dev \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git for safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser

# Change ownership of workspace to testuser
RUN chown -R testuser /workspace

# Switch to non-root user BEFORE installing Rust
USER testuser

# Install Rust toolchain as testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set Rust environment for testuser
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Read and install pinned Rust version from rust-toolchain.toml
RUN rustup show

# Copy and prepare run script
COPY --chown=testuser:testuser run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]