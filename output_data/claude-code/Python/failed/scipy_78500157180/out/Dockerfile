FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CCACHE_DIR="/app/.ccache"
ENV CCACHE_MAXSIZE="250M"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libopenblas-dev \
    libatlas-base-dev \
    liblapack-dev \
    gfortran \
    libgmp-dev \
    libmpfr-dev \
    libsuitesparse-dev \
    ccache \
    libmpc-dev \
    build-essential \
    curl \
    git \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.14-dev
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.14-dev \
    python3.14-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Install pip for Python 3.14 and then install Python packages
RUN python3.14 -m ensurepip --upgrade && \
    python3.14 -m pip install --upgrade setuptools wheel && \
    python3.14 -m pip install git+https://github.com/numpy/numpy.git && \
    python3.14 -m pip install ninja cython pytest pybind11 pytest-xdist pytest-timeout spin pooch hypothesis "setuptools<67.3" meson "click<8.3.0" && \
    python3.14 -m pip install git+https://github.com/serge-sans-paille/pythran.git

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
