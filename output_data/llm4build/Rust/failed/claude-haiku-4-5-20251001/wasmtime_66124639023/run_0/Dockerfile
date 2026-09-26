FROM ubuntu:24.04

# Set timezone noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    util-linux \
    cmake \
    ninja-build \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install VTune (Intel Performance Profiler)
RUN apt-get update && apt-get install -y --no-install-recommends \
    intel-oneapi-vtune \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy the repository
COPY . /workspace/

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]