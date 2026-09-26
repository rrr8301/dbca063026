FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/python/cp314-cp314/bin:$PATH

# Install base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    python3 \
    python3-dev \
    python3-pip \
    libopenblas-dev \
    liblapack-dev \
    graphviz \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install CMake 3.28+
RUN curl -fsSL https://cmake.org/files/v3.28/cmake-3.28.5-linux-x86_64.tar.gz -o cmake.tar.gz && \
    tar -xzf cmake.tar.gz -C /opt && \
    ln -sf /opt/cmake-3.28.5-linux-x86_64/bin/cmake /usr/local/bin/cmake && \
    ln -sf /opt/cmake-3.28.5-linux-x86_64/bin/ctest /usr/local/bin/ctest && \
    rm cmake.tar.gz

# Create Python 3.14 directory structure to match the expected layout
RUN mkdir -p /opt/python/cp314-cp314/bin && \
    ln -sf /usr/bin/python3 /opt/python/cp314-cp314/bin/python3.14 && \
    ln -sf /usr/bin/python3 /opt/python/cp314-cp314/bin/python

# Install pip dependencies
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install ONNX Runtime build dependencies
RUN python3 -m pip install \
    numpy \
    protobuf \
    onnx \
    sympy \
    cffi \
    pybind11 \
    pytest \
    pytest-cov \
    packaging \
    flatbuffers \
    psutil \
    py-cpuinfo

WORKDIR /app

COPY repo /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
