FROM ubuntu:22.04

# Set timezone noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build tools and C++ dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    cmake \
    cmake-curses-gui \
    libboost-all-dev \
    libprotobuf-dev \
    libgtest-dev \
    libre2-dev \
    libicu-dev \
    libboost-dev \
    libboost-thread-dev \
    libboost-system-dev \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]