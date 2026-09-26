FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update -y && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    gcc-14 \
    g++-14 \
    git \
    make \
    pkg-config \
    python3 \
    python3-pip \
    curl \
    wget \
    nasm \
    meson \
    libpng-dev \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-c
RUN cargo install cargo-c --features=vendored-openssl

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]