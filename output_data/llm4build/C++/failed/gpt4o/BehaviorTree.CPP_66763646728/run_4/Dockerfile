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
    python3 \
    python3-pip \
    build-essential \
    ninja-build \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install a compatible version of CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.0/cmake-3.24.0-linux-x86_64.sh && \
    chmod +x cmake-3.24.0-linux-x86_64.sh && \
    ./cmake-3.24.0-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.24.0-linux-x86_64.sh

# Install Conan using pip
RUN pip3 install conan

# Set up work directory
WORKDIR /workspace

# Copy the repository into the Docker image
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create a non-root user and switch to it
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Ensure run.sh is executable
RUN chmod +x /workspace/run.sh

# Entry point
CMD ["bash", "/workspace/run.sh"]