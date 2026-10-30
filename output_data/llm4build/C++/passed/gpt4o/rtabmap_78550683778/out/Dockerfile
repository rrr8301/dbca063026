FROM ubuntu:22.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV DEBIAN_FRONTEND=noninteractive

# Set locale to UTF-8
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Install dependencies including compilers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \ 
    libopencv-dev \
    libpcl-dev \
    git \
    cmake \
    software-properties-common \
    libyaml-cpp-dev \
    libunwind-dev \
    libceres-dev \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Set up Python
RUN python3 -m pip install --upgrade pip && \
    pip install numpy pybind11

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