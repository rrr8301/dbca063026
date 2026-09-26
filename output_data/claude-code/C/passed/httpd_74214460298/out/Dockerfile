FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV PATH=$HOME/root/apr-1.7.4/bin:$HOME/root/apr-util-1.6.3/bin:$PATH
ENV LD_LIBRARY_PATH=$HOME/root/apr-1.7.4/lib:$HOME/root/apr-util-1.6.3/lib:$LD_LIBRARY_PATH

RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    perl \
    python3-pytest \
    python3-cryptography \
    python3-requests \
    python3-multipart \
    python3-filelock \
    python3-websockets \
    git \
    curl \
    wget \
    gdb \
    perl-doc \
    cpanminus \
    libtool-bin \
    libapr1-dev \
    libaprutil1-dev \
    liblua5.3-dev \
    libbrotli-dev \
    libcurl4-openssl-dev \
    libnghttp2-dev \
    libjansson-dev \
    libpcre2-dev \
    libsasl2-dev \
    nghttp2-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN mkdir -p $HOME/build $HOME/root && \
    git config --global advice.detachedHead false && \
    chmod +x /app/test/travis_before_linux.sh /app/test/travis_run_linux.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
