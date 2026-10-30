FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    binutils-dev \
    bison \
    build-essential \
    cmake \
    curl \
    flex \
    git \
    libaio-dev \
    libcap-dev \
    libcrypt-dev \
    libdwarf-dev \
    libevent-dev \
    libffi-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libkeyutils-dev \
    libkeyutils1 \
    libldap-dev \
    liblz4-dev \
    libmariadb-dev \
    libpthread-stubs0-dev \
    libsnappy-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libsystemd-dev \
    libtool \
    libudev-dev \
    libunwind-dev \
    libx11-dev \
    libxml2-dev \
    libzstd-dev \
    libiberty-dev \
    ninja-build \
    pkg-config \
    python3 \
    sudo \
    texinfo \
    unzip \
    wget \
    xz-utils \
    zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive folly && \
    python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

RUN python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. folly --project-install-prefix folly:/usr/local 2>&1 | tee build.log

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
