FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    libasound2-dev \
    mesa-vulkan-drivers \
    libudev-dev \
    libfontconfig-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain (as root)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-nextest
RUN cargo install cargo-nextest --locked

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV CARGO_INCREMENTAL=1
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV XDG_RUNTIME_DIR=

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow ownership mismatches
RUN git config --global --add safe.directory '*'

# Set entrypoint (run as root to access Rust toolchain)
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]