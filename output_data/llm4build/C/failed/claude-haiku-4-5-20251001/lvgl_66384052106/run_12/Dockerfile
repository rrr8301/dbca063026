FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Enable i386 architecture and update
RUN dpkg --add-architecture i386 && apt-get update

# Install system dependencies
RUN apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    gcc \
    gcc-multilib \
    g++ \
    g++-multilib \
    make \
    ninja-build \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    libpng-dev \
    libpng-dev:i386 \
    libjpeg-dev \
    libjpeg-dev:i386 \
    libjpeg-turbo8-dev \
    libwebp-dev \
    libfreetype-dev \
    libglfw3-dev \
    libsdl2-dev \
    zlib1g-dev \
    pkg-config \
    curl \
    wget \
    sudo \
    ruby-full \
    gcovr \
    libinput-dev \
    libxkbcommon-dev \
    libdrm-dev \
    wayland-protocols \
    libwayland-dev \
    libwayland-bin \
    libudev-dev \
    libavformat-dev \
    libavcodec-dev \
    libswscale-dev \
    libavutil-dev \
    libuv1-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Create virtual environment
RUN python3.12 -m venv /workspace/venv
ENV PATH="/workspace/venv/bin:$PATH"

# Upgrade pip in virtual environment
RUN /workspace/venv/bin/pip install --upgrade pip setuptools wheel

# Install Python prerequisites directly
RUN /workspace/venv/bin/pip install pypng lz4 kconfiglib

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]