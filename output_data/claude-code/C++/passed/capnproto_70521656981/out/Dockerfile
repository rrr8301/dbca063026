FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-upgrade --no-install-recommends -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    cmake \
    pkg-config \
    git \
    libssl-dev \
    zlib1g-dev \
    python3 \
    clang-18 \
    libc++-18-dev \
    libc++abi-18-dev \
    libclang-rt-18-dev \
    lld-18 \
    llvm-18 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
