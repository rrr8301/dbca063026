FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install Python build tools with --break-system-packages for Ubuntu 24.04 PEP 668 compliance
# Note: Only upgrade setuptools; wheel is installed by debian and lacks RECORD file, so do not upgrade it
RUN python -m pip install --break-system-packages --upgrade setuptools

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]