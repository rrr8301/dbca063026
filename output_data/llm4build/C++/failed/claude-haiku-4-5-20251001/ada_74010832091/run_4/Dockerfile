FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    g++-12 \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust using the official installer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Update Rust to latest stable to support Cargo.lock v4
RUN rustup update stable

# Create work directory
WORKDIR /workspace

# Copy the entire repository into the container
COPY . /workspace/

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]