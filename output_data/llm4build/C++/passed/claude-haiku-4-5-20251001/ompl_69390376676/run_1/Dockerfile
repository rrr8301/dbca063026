FROM ubuntu:24.04

# Set timezone and CI environment variables
ENV TZ=America/Los_Angeles
ENV CI=true
ENV GITHUB_ACTIONS=true

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    git \
    cmake \
    g++ \
    make \
    python3 \
    python3-dev \
    python3-pip \
    libboost-program-options-dev \
    libboost-serialization-dev \
    libboost-test-dev \
    libeigen3-dev \
    libflann-dev \
    libtriangle-dev \
    libyaml-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy the repository (assumes build context is the repo root)
COPY . /workspace/

# Initialize git config for submodule operations
RUN git config --global --add safe.directory /workspace

# Install Python dependencies with --break-system-packages for Ubuntu 24.04
RUN python3 -m pip install --upgrade pip --break-system-packages && \
    pip install pytest scikit-build --break-system-packages

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]