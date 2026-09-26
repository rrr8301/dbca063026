FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust stable toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:${PATH}"

# Install mdBook 0.5.2
RUN curl -L https://github.com/rust-lang/mdBook/releases/download/v0.5.2/mdbook-v0.5.2-x86_64-unknown-linux-gnu.tar.gz | \
    tar xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/mdbook

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow workspace directory (avoid ownership errors)
RUN git config --global --add safe.directory '*'

# Initialize submodules
RUN git submodule update --init --recursive

# Create non-root user and set up Rust environment for them
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace && \
    mkdir -p /home/testuser/.cargo && \
    cp /root/.cargo/env /home/testuser/.cargo/env && \
    cp -r /root/.cargo/bin /home/testuser/.cargo/ && \
    chown -R testuser:testuser /home/testuser/.cargo

# Switch to non-root user
USER testuser

# Set Rust environment for testuser
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]