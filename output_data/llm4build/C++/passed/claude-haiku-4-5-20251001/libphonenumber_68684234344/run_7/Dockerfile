FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    cmake-curses-gui \
    libboost-all-dev \
    libboost-dev \
    libboost-thread-dev \
    libboost-system-dev \
    libprotobuf-dev \
    libgtest-dev \
    libre2-dev \
    libicu-dev \
    protobuf-compiler \
    pkg-config \
    ca-certificates \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]