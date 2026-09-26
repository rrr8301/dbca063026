FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    curl \
    wget \
    ca-certificates \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Install Miniforge (includes Conda and Mamba)
RUN curl -fsSLo /tmp/Miniforge3-Linux-x86_64.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && \
    bash /tmp/Miniforge3-Linux-x86_64.sh -b -p /opt/miniforge3 && \
    rm /tmp/Miniforge3-Linux-x86_64.sh

# Initialize conda
RUN /opt/miniforge3/bin/conda init bash

# Copy repository
COPY . /workspace/

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]