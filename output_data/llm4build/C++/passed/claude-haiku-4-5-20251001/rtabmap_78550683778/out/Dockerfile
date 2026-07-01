FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV CI=true
ENV GITHUB_ACTIONS=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    software-properties-common \
    build-essential \
    g++ \
    make \
    curl \
    libopencv-dev \
    libpcl-dev \
    libyaml-cpp-dev \
    libunwind-dev \
    libceres-dev \
    python3 \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Install Python dependencies
RUN python3 -m pip install --upgrade pip && \
    pip install numpy pybind11

# Fetch test data as root (before switching to non-root user)
RUN bash scripts/fetch_test_data.sh

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]