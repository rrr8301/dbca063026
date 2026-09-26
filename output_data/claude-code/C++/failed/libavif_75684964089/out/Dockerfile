FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    python3 \
    python3-pip \
    nasm \
    meson \
    ninja-build \
    cmake \
    cargo \
    rustc \
    pkg-config \
    libjpeg-turbo8-dev \
    libxml2 \
    libyuv-dev \
    libpng-dev \
    libz-dev \
    curl \
    gcc-14 \
    g++-14 \
    && rm -rf /var/lib/apt/lists/*

# Set up GCC 14 as default (if it was installed)
RUN which gcc-14 && (update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100) || true

# Update Rust to a newer version for cargo-c compatibility
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN /bin/bash -c "source $HOME/.cargo/env && rustup update stable"

# Install cargo-c for rav1e
RUN /bin/bash -c "source $HOME/.cargo/env && cargo install cargo-c --features=vendored-openssl"

WORKDIR /app
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
