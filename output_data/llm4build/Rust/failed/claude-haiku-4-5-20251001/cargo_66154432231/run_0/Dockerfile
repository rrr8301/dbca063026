FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Set Rust-specific environment variables from the workflow
ENV CARGO_PROFILE_DEV_DEBUG=1
ENV CARGO_PROFILE_TEST_DEBUG=1
ENV CARGO_INCREMENTAL=0
ENV CARGO_PUBLIC_NETWORK_TESTS=1
ENV RUSTUP_WINDOWS_PATH_ADD_BIN=0

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    ca-certificates \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]