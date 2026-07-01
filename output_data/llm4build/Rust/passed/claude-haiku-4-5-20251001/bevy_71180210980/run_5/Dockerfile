FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies (including ca-certificates for HTTPS)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    build-essential \
    pkg-config \
    libasound2-dev \
    libudev-dev \
    libwayland-dev \
    && rm -rf /var/lib/apt/lists/*

# Set HOME explicitly
ENV HOME=/root

# Install Rust stable toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    chmod -R a+w $HOME/.cargo

# Add Rust to PATH - this must be set in ENV for persistence
ENV PATH="$HOME/.cargo/bin:$PATH"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/bin/bash", "-l", "-c", "/workspace/run.sh"]