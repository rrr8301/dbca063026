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

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-dev \
    autoconf \
    automake \
    libtool \
    && rm -rf /var/lib/apt/lists/*

# Install Rust stable via rustup (as root, before creating non-root user)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Create non-root user and set up Rust for them
RUN useradd -m testuser && \
    cp -r /root/.cargo /home/testuser/.cargo && \
    cp -r /root/.rustup /home/testuser/.rustup && \
    chown -R testuser:testuser /home/testuser/.cargo /home/testuser/.rustup && \
    chown -R testuser:testuser /workspace

USER testuser

ENV PATH="/home/testuser/.cargo/bin:${PATH}"

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]