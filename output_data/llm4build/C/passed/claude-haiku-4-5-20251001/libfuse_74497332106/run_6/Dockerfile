FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    cmake \
    ninja-build \
    meson \
    gcc \
    g++ \
    clang \
    clang++ \
    make \
    curl \
    wget \
    ca-certificates \
    sudo \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Configure sudo to not require password for root
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Create working directory
WORKDIR /workspace

# Copy the repository
COPY . .

# Install Python dependencies from requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt || true

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]