FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies (including ca-certificates for HTTPS)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    build-essential \
    clang \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust nightly with rust-src component
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain nightly \
    --profile minimal

# Source Rust environment for subsequent RUN commands
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Add rust-src component after Rust is installed
RUN rustup component add rust-src

ENTRYPOINT ["/workspace/run.sh"]