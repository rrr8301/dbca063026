FROM ubuntu:22.04

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

# Install Python 3.14-dev from deadsnakes PPA
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.14-dev python3.14-venv python3.14-distutils && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.14 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

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