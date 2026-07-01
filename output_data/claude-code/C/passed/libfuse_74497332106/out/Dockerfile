FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Add i386 architecture for 32-bit support
RUN dpkg --add-architecture i386

# Install core dependencies
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
    libudev-dev:i386 \
    python3-pytest \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Install Python dependencies
RUN pip install -r requirements.txt

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
