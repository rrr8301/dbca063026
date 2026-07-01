FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3-pip \
    python3-distutils \
    build-essential \
    gfortran \
    libopenblas-dev \
    libatlas-base-dev \
    liblapack-dev \
    libgmp-dev \
    libmpfr-dev \
    libsuitesparse-dev \
    libmpc-dev \
    ccache \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Upgrade pip using the system python
RUN python3.12 -m pip install --upgrade pip setuptools wheel

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
    mypy==1.19.1 \
    types-psutil \
    typing_extensions \
    sphinx \
    "click<8.3.0"

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Create run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
