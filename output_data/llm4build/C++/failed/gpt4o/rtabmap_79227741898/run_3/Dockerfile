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
    build-essential \  # Added to install C and C++ compilers
    libopencv-dev \
    libpcl-dev \
    git \
    cmake \
    software-properties-common \
    libyaml-cpp-dev \
    libunwind-dev \
    libceres-dev \
    python3 \
    python3-pip \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Set up Python
RUN python3 -m pip install --upgrade pip && \
    pip install numpy pybind11 torch  # Added torch to resolve the missing torch error

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Create a non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Entry point
CMD ["/bin/bash", "/workspace/run.sh"]