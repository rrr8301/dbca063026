FROM ubuntu:24.04

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
    build-essential \
    cmake \
    curl \
    wget \
    python3 \
    python3-pip \
    util-linux \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Set up Rust environment variables (will be sourced in run.sh)
ENV RUSTUP_HOME=/home/testuser/.rustup \
    CARGO_HOME=/home/testuser/.cargo \
    PATH=/home/testuser/.cargo/bin:$PATH \
    CARGO_INCREMENTAL=0 \
    CARGO_PROFILE_DEV_DEBUG=0 \
    CARGO_PROFILE_TEST_DEBUG=0 \
    RUSTFLAGS="-D warnings" \
    WIT_REQUIRE_SEMICOLONS=1

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]