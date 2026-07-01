FROM ubuntu:22.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3-pip \
    wget \
    pkg-config \
    libzmq3-dev && \  # Add ZeroMQ development package
    rm -rf /var/lib/apt/lists/*

# Install a compatible version of CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.23.0/cmake-3.23.0-linux-x86_64.sh && \
    chmod +x cmake-3.23.0-linux-x86_64.sh && \
    ./cmake-3.23.0-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.23.0-linux-x86_64.sh

# Install Conan
RUN pip3 install conan

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]