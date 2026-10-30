FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NPROC=4

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    git \
    curl \
    build-essential \
    cmake \
    ninja-build \
    python3 \
    python3-dev \
    python3-pip \
    libomp-dev \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Install Python build dependencies (skip pip upgrade due to Debian pkg constraints)

# Copy the repository
COPY repo/ /app/
WORKDIR /app

# Install Python dependencies for building
RUN python3 -m pip install --break-system-packages \
    pybind11==3.0 \
    cmake==3.30.0 \
    ninja==1.11.1 \
    pytest \
    pytest-xdist \
    scikit-build-core \
    setuptools_scm

# Set up environment variables
ENV CC=gcc
ENV CXX=g++
ENV CMAKE_GENERATOR=Ninja
ENV CMAKE_BUILD_PARALLEL_LEVEL=4

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
