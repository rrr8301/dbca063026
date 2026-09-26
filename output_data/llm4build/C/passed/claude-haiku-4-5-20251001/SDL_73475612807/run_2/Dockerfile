FROM ubuntu:latest

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    autoconf \
    automake \
    libtool \
    clang \
    clang-tools \
    curl \
    wget \
    ca-certificates \
    libx11-dev \
    libxext-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxi-dev \
    libxss-dev \
    libxkbcommon-dev \
    libwayland-dev \
    libxdamage-dev \
    libxfixes-dev \
    wayland-protocols \
    libdecor-0-dev \
    libpulse-dev \
    libasound2-dev \
    libpipewire-0.3-dev \
    libsndio-dev \
    libvulkan-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make run script executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]