FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV AR=x86_64-linux-gnu-ar
ENV CHOST=x86_64-linux-gnu
ENV CC=x86_64-linux-gnu-gcc
ENV CPP=x86_64-linux-gnu-cpp
ENV LDFLAGS=-s
ENV SUFFIX=linux-amd64

RUN apt-get update && apt-get install -y \
    automake \
    autoconf \
    libtool \
    crossbuild-essential-amd64 \
    git \
    file \
    tzdata

WORKDIR /app
COPY repo/ /app/

RUN cd /app && git submodule update --init --recursive && autoreconf -i && \
    ./configure \
    --host=x86_64-linux-gnu \
    --disable-docs \
    --with-oniguruma=builtin \
    --enable-static \
    --enable-all-static \
    CFLAGS="-O2 -pthread -fstack-protector-all" && \
    make -j$(nproc) && \
    file ./jq && \
    cp ./jq jq-${SUFFIX}

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
