FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    gcc \
    g++ \
    make \
    pkg-config \
    autoconf \
    automake \
    libtool \
    python3 \
    python3-pip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint (before changing ownership)
COPY run.sh /workspace/run.sh

# Fix permissions for all scripts (while still root)
RUN chmod +x /workspace/sys/*.sh && \
    find /workspace -name "configure" -type f -exec chmod +x {} \; && \
    chmod +x /workspace/run.sh && \
    chown -R builder:builder /workspace

# Switch to non-root user
USER builder

# Install Python dependencies
RUN python3 -m pip install --upgrade pip && \
    pip3 install --user r2pipe wheel

ENTRYPOINT ["/workspace/run.sh"]