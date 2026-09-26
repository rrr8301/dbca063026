FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Add i386 architecture for 32-bit support first
RUN dpkg --add-architecture i386

# Install system dependencies
# Note: pkg-config and pkg-config:i386 conflict, so we only install amd64 version
RUN apt-get update && apt-get install -y \
    gcc \
    meson \
    ninja-build \
    libudev-dev \
    liburing-dev \
    libnuma-dev \
    pkg-config \
    python3 \
    python3-pip \
    clang \
    doxygen \
    gcc-10 \
    gcc-9 \
    valgrind \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    libpcap0.8-dev:i386 \
    libudev-dev:i386 \
    python3-pytest \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

# Install Python dependencies - skip codechecker as it has build issues
RUN pip install meson ninja pytest

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
