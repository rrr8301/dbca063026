FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CC=clang
ENV CXX=clang++

RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    cmake \
    ninja-build \
    ccache \
    clang \
    lld \
    git \
    wget \
    curl \
    pkg-config \
    zlib1g-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

RUN python3 -m pip install --no-cache-dir \
    -f https://download.pytorch.org/whl/nightly/cpu/torch/ \
    --pre torch==2.12.0.dev20260323+cpu

RUN python3 -m pip install --no-cache-dir \
    -f https://download.pytorch.org/whl/nightly/cpu/torchvision/ \
    --pre --upgrade torchvision

RUN python3 -m pip install --no-cache-dir -r build-requirements.txt \
    && python3 -m pip install --no-cache-dir -r test-requirements.txt

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
