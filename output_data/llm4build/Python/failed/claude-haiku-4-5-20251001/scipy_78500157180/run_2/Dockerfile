FROM python:3.14-rc-slim

# Set timezone and environment variables
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    CI=true \
    GITHUB_ACTIONS=true \
    CCACHE_DIR=/workspace/.ccache \
    CCACHE_MAXSIZE=250M

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    libopenblas-dev \
    libatlas-base-dev \
    liblapack-dev \
    gfortran \
    libgmp-dev \
    libmpfr-dev \
    libsuitesparse-dev \
    ccache \
    libmpc-dev \
    curl \
    wget \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Install Python build tools and dependencies
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install git+https://github.com/numpy/numpy.git && \
    python -m pip install ninja cython pytest pybind11 pytest-xdist pytest-timeout spin pooch hypothesis "setuptools<67.3" meson "click<8.3.0" && \
    python -m pip install git+https://github.com/serge-sans-paille/pythran.git

# Initialize ccache
RUN mkdir -p "${CCACHE_DIR}" && ccache --zero-stats

# Copy and set up run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]