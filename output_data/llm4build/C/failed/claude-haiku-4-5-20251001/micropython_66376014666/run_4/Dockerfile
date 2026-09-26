FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set non-interactive environment for apt-get
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV APTARGS="-y --no-install-recommends"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    gcc \
    g++ \
    gcc-multilib \
    g++-multilib \
    make \
    cmake \
    pkg-config \
    libffi-dev \
    libffi-dev:i386 \
    libssl-dev \
    libssl-dev:i386 \
    python3.11 \
    python3.11-dev \
    python3-pip \
    bash \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Configure sudo to work without password for root
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Create working directory
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]