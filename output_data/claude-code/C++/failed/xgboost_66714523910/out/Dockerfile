FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    wget \
    ca-certificates \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    libomp-dev \
    libnuma-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Initialize git submodules
RUN cd /app && git submodule update --init --recursive

# Create virtual environment
RUN python3.12 -m venv /venv
ENV PATH="/venv/bin:${PATH}"

# Upgrade pip and install build tools
RUN pip install --upgrade pip setuptools wheel

# Install Python dependencies for testing
RUN pip install \
    cmake>=3.26.4 \
    ninja \
    pyyaml \
    cpplint \
    pylint \
    numpy \
    scipy \
    'scikit-learn>=1.4.1' \
    pandas \
    polars \
    matplotlib \
    'dask<=2024.10.0' \
    'distributed<=2024.10.0' \
    graphviz \
    'hypothesis>=6.46' \
    astroid \
    sh \
    mock \
    pytest \
    pytest-timeout \
    pytest-cov \
    python-kubernetes \
    urllib3 \
    boto3 \
    awscli \
    py-ubjson \
    'loky>=3.5.1' \
    pyarrow \
    protobuf \
    cloudpickle \
    modin \
    'pyspark>=4.0.0'

# Build XGBoost
RUN mkdir -p build && \
    cd build && \
    cmake .. \
      -GNinja \
      -DHIDE_CXX_SYMBOLS=ON \
      -DENABLE_ALL_WARNINGS=OFF \
      -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF && \
    ninja -v

# Build Python wheel
RUN cd /app/python-package && \
    pip wheel --no-deps -v . --wheel-dir /app/wheelhouse/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
