FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ccache \
    ninja-build \
    cmake \
    git \
    clang \
    lld \
    python3.11 \
    python3.11-dev \
    python3-pip \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

WORKDIR /app

COPY repo/ /app/

RUN git submodule update --init --recursive

RUN python3 -m pip install --no-cache-dir wheel setuptools ninja packaging pyyaml

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
