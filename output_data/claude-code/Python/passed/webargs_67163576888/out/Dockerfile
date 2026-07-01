FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    libffi-dev \
    libsqlite3-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://www.python.org/ftp/python/3.14.0/Python-3.14.0.tar.xz -o /tmp/python.tar.xz && \
    cd /tmp && \
    tar xf python.tar.xz && \
    cd Python-3.14.0 && \
    ./configure --prefix=/usr/local --enable-optimizations && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/Python-3.14.0 /tmp/python.tar.xz

RUN python3.14 -m pip install --upgrade pip setuptools wheel

WORKDIR /app

COPY repo/ /app/

RUN python3.14 -m pip install tox

RUN python3.14 -m pip install flit_core

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
