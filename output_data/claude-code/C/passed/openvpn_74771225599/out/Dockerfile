FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    liblzo2-dev \
    libpam0g-dev \
    liblz4-dev \
    libcap-ng-dev \
    libnl-genl-3-dev \
    linux-libc-dev \
    man2html \
    libcmocka-dev \
    python3-docutils \
    libtool \
    automake \
    autoconf \
    libssl-dev \
    libpkcs11-helper1-dev \
    softhsm2 \
    gnutls-bin \
    pkg-config \
    sudo \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
