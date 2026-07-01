FROM ubuntu:22.04

# Set timezone to Pacific Time and avoid interactive prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV CCACHE_DIR="/workspace/.ccache"
ENV CCACHE_MAXSIZE="250M"

# Install system dependencies and add deadsnakes PPA for Python 3.12
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    ninja-build \
    ccache \
    pkg-config \
    libopenblas-dev \
    libatlas-base-dev \
    liblapack-dev \
    gfortran \
    libgmp-dev \
    libmpfr-dev \
    libsuitesparse-dev \
    libmpc-dev \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12 (distutils removed in Python 3.12, use ensurepip instead)
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Upgrade pip using ensurepip for Python 3.12
RUN python3.12 -m ensurepip --upgrade && \
    python -m pip install --upgrade pip setuptools wheel

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow the workspace directory
RUN git config --global --add safe.directory '*'

# Install Python build and test dependencies
RUN python -m pip install \
    numpy \
    cython \
    pytest \
    pytest-xdist \
    pytest-timeout \
    pybind11 \
    mpmath \
    gmpy2 \
    pythran \
    ninja \
    meson \
    pooch \
    hypothesis \
    spin \
    'click<8.3.0' \
    mypy==1.19.1 \
    types-psutil \
    typing_extensions \
    sphinx

# Install dev requirements
RUN python -m pip install -r requirements/dev.txt

# Copy and set up run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]