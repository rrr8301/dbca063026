FROM ubuntu:24.04

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
    CARGO_PROFILE_TEST_DEBUG=0 \
    CARGO_PROFILE_DEV_DEBUG=0 \
    CARGO_PROFILE_RELEASE_DEBUG=0 \
    CARGO_TERM_COLOR=always \
    RUST_BACKTRACE=full

# Install build dependencies including Python 3
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    python3 \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user first
RUN useradd -m testuser

# Install Rust stable toolchain as testuser
USER testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY --chown=testuser:testuser . /workspace/

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]