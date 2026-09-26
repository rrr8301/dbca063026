FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    FORCE_COLOR=1 \
    PYTHONSTRICTEXTENSIONBUILD=1 \
    TERM=linux \
    OPENSSL_VER=3.5.5

WORKDIR /app

RUN apt-get update && apt-get install -yq --no-install-recommends \
    git \
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
    python3 \
    python3-venv \
    wget \
    sudo \
    software-properties-common

RUN add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get -yq --no-install-recommends install libmpdec-dev

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
