FROM ubuntu:24.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    autoconf \
    automake \
    libtool \
    pkg-config \
    cmake \
    git \
    sudo \
    curl \
    wget \
    clang \
    liblzo2-dev \
    libpam0g-dev \
    liblz4-dev \
    linux-libc-dev \
    man2html \
    libcmocka-dev \
    python3-docutils \
    python3-jinja2 \
    python3-jsonschema \
    libcap-ng-dev \
    libnl-genl-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Build mbed TLS v4.1.0 from source
RUN git clone --depth 1 --branch v4.1.0 --recurse-submodules https://github.com/Mbed-TLS/mbedtls.git /tmp/mbedtls && \
    cd /tmp/mbedtls && \
    git submodule update --init --recursive && \
    cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/mbedtls4 && \
    cmake --build build && \
    cmake --install build && \
    rm -rf /tmp/mbedtls

# Copy OpenVPN repository
COPY . /workspace/

# Set environment variables
ENV CFLAGS="-O2 -g"
ENV LDFLAGS=""
ENV CC=gcc
ENV UBSAN_OPTIONS=print_stacktrace=1
ENV PKG_CONFIG_PATH=/opt/mbedtls4/lib/pkgconfig
ENV MBEDTLS_REPO=Mbed-TLS/mbedtls
ENV MBEDTLS_VERSION=v4.1.0
ENV MBEDTLS_INSTALL=/opt/mbedtls4

# Copy and set run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]