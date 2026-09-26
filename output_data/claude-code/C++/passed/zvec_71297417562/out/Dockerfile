FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-dev \
    python3-pip \
    ninja-build \
    clang-format \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN cd /app && git submodule update --init --recursive

RUN python3 -m pip install --break-system-packages \
    pybind11==3.0 \
    cmake==3.30.0 \
    ninja==1.11.1 \
    pytest \
    scikit-build-core \
    setuptools_scm

RUN mkdir -p /app/build && \
    cd /app && \
    CMAKE_GENERATOR="Unix Makefiles" \
    CMAKE_BUILD_PARALLEL_LEVEL=4 \
    python3 -m pip install -v . \
    --no-build-isolation \
    --break-system-packages \
    --config-settings='cmake.define.BUILD_TOOLS="ON"'

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
