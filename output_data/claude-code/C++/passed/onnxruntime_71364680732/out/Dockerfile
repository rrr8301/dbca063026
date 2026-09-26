FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    wget \
    git-lfs \
    software-properties-common \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    nodejs \
    npm \
    openjdk-17-jdk \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools wheel

WORKDIR /app

COPY repo/ /app/

RUN python3 -m pip install -r requirements-dev.txt

RUN python3 -m pip install -r tools/ci_build/github/linux/docker/scripts/requirements.txt

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
