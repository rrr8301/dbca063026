FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBPREFIX=/opt/mbedtls
ENV CFLAGS="-O2 -g"
ENV LDFLAGS=""
ENV CC=gcc
ENV CXX=g++
ENV UBSAN_OPTIONS=print_stacktrace=1
ENV PKG_CONFIG_PATH=$LIBPREFIX/lib/pkgconfig

# Install system dependencies
RUN apt-get update && apt-get install -y \
    liblzo2-dev \
    libpam0g-dev \
    liblz4-dev \
    linux-libc-dev \
    man2html \
    clang \
    libcmocka-dev \
    python3-docutils \
    python3-jinja2 \
    python3-jsonschema \
    python3-pip \
    python3-cryptography \
    python3-yaml \
    libtool \
    automake \
    autoconf \
    pkg-config \
    libcap-ng-dev \
    libnl-genl-3-dev \
    build-essential \
    git \
    cmake \
    wget \
    sudo \
    perl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the OpenVPN repository
COPY repo/ /app/

# Create the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
