FROM ubuntu:22.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    curl \
    wget \
    g++ \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Install Meson and Ninja via pip
RUN pip3 install --no-cache-dir meson==1.5.1 ninja==1.11.1.1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]