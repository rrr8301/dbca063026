FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Set CI environment variables
ENV CI=true \
    GITHUB_ACTIONS=true \
    CARGO_INCREMENTAL=0 \
    CARGO_NET_RETRY=10 \
    CARGO_TERM_COLOR=always \
    RUSTUP_MAX_RETRIES=10 \
    PACKAGE_NAME=ruff \
    PYTHON_VERSION=3.14 \
    NEXTEST_PROFILE=ci \
    MDTEST_EXTERNAL=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    mold \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:${PATH}"

# Install Python 3.14 (try deadsnakes PPA, fallback to 3.12 if unavailable)
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa 2>/dev/null || true \
    && apt-get update \
    && (apt-get install -y --no-install-recommends python3.14 python3.14-venv python3.14-dev || \
        apt-get install -y --no-install-recommends python3.12 python3.12-venv python3.12-dev) \
    && rm -rf /var/lib/apt/lists/*

# Install uv (pinned version 0.10.7)
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

# Install cargo-insta only (cargo-nextest will be installed via pre-built binary)
RUN . /root/.cargo/env && cargo install cargo-insta

# Install cargo-nextest via pre-built binary
RUN curl -LsSf https://github.com/nextest-rs/nextest/releases/download/cargo-nextest-0.9.137/cargo-nextest-0.9.137-x86_64-unknown-linux-gnu.tar.gz | tar xzf - -C /root/.cargo/bin

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git (avoid ownership errors)
RUN git config --global --add safe.directory '*'

# Create non-root user and set up Rust environment
RUN useradd -m testuser && chown -R testuser /workspace && \
    mkdir -p /home/testuser/.cargo && \
    cp -r /root/.cargo/* /home/testuser/.cargo/ && \
    chown -R testuser:testuser /home/testuser/.cargo

# Switch to non-root user
USER testuser

# Set PATH for non-root user
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]