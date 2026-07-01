FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    python3 \
    python3-dev \
    curl \
    wget \
    pkg-config \
    libssl-dev \
    libzstd-dev \
    libbz2-dev \
    liblz4-dev \
    libsnappy-dev \
    libdouble-conversion-dev \
    libgflags-dev \
    libgtest-dev \
    libevent-dev \
    libboost-all-dev \
    ninja-build \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]