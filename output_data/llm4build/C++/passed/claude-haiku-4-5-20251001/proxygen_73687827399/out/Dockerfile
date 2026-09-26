FROM ubuntu:22.04

# Set timezone and avoid interactive prompts
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive

# Update package lists and install dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    curl \
    wget \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Configure sudo to work without password
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint with proper line endings
COPY run.sh /workspace/run.sh
RUN dos2unix /workspace/run.sh 2>/dev/null || sed -i 's/\r$//' /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]