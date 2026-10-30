FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV MARGS="-j2"
ENV CFLAGS="-g"
ENV PHP_FPM="/usr/sbin/php-fpm8.1"
ENV APR_VERSION=1.7.4
ENV APU_VERSION=1.6.3
ENV APU_CONFIG="--with-crypto"
ENV NO_TEST_FRAMEWORK=1
ENV TEST_INSTALL=1
ENV TEST_H2=1
ENV TEST_CORE=1
ENV TEST_PROXY=1
ENV HOME=/root

RUN apt-get -o Acquire::Retries=5 update && \
    apt-get install -o Acquire::Retries=5 -y \
    sudo wget git curl build-essential \
    cpanminus libtool-bin libapr1-dev libaprutil1-dev \
    liblua5.3-dev libbrotli-dev libcurl4-openssl-dev \
    libnghttp2-dev libjansson-dev libpcre2-dev gdb \
    perl-doc libsasl2-dev \
    python3-pytest nghttp2-client python3-cryptography \
    python3-requests python3-multipart python3-filelock python3-websockets \
    libxml2-dev libcrypt-dev openssl libssl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app /home/runner/build
WORKDIR /app
COPY repo/ /app/

RUN mkdir -p $HOME/root $HOME/build $HOME/perl5 && \
    sysctl -w vm.mmap_rnd_bits=28 || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
