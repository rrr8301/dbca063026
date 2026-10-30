FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Python and system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    git \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    curl \
    wget \
    xvfb \
    sway \
    wayland-protocols \
    libwayland-dev \
    libjpeg-turbo8-dev \
    zlib1g-dev \
    libtiff-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Remove PEP 668 restriction to allow pip installs in Docker
RUN rm -f /usr/lib/python3.12/EXTERNALLY-MANAGED

# Upgrade pip using --ignore-installed to handle Debian-installed pip without RECORD file
RUN python3 -m pip install --no-cache-dir --upgrade --ignore-installed --break-system-packages pip

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]