FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    git \
    build-essential \
    g++ \
    gcc \
    make \
    cmake \
    ninja-build \
    libomp-dev \
    python3-dev \
    python3-pip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install Python dependencies
RUN python3 -m pip install --no-cache-dir --break-system-packages \
    pybind11==3.0 \
    cmake==3.30.0 \
    ninja==1.11.1 \
    pytest \
    scikit-build-core \
    setuptools_scm

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]