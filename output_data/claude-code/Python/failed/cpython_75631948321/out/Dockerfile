FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    FORCE_COLOR=1 \
    PYTHONSTRICTEXTENSIONBUILD=1 \
    TERM=linux

WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get -yq --no-install-recommends install \
        ca-certificates \
        build-essential \
        pkg-config \
        cmake \
        gdb \
        lcov \
        libb2-dev \
        libbz2-dev \
        libffi-dev \
        libgdbm-dev \
        libgdbm-compat-dev \
        liblzma-dev \
        libncurses5-dev \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        libzstd-dev \
        lzma \
        lzma-dev \
        strace \
        tk-dev \
        uuid-dev \
        xvfb \
        zlib1g-dev \
        curl \
        git \
        python3

# Install mpdecimal from source (workaround for missing libmpdec-dev on ubuntu 24.04)
RUN MPDECIMAL_VERSION=4.0.1 && \
    curl -fsSL "https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-${MPDECIMAL_VERSION}.tar.gz" | tar -xz -C /tmp && \
    cd "/tmp/mpdecimal-${MPDECIMAL_VERSION}" && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Copy the repository
COPY repo/ /app/

# Set up OpenSSL environment
ENV OPENSSL_VER=3.5.6 \
    MULTISSL_DIR=/app/multissl \
    OPENSSL_DIR=/app/multissl/openssl/3.5.6 \
    LD_LIBRARY_PATH=/app/multissl/openssl/3.5.6/lib

# Install OpenSSL
RUN python3 Tools/ssl/multissltests.py --steps=library --base-directory "$MULTISSL_DIR" --openssl "$OPENSSL_VER" --system Linux

# Set up build directories
RUN mkdir -p /build_dir

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
