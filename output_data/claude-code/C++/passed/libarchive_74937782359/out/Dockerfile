FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    build-essential \
    cmake \
    git \
    libssl-dev \
    nettle-dev \
    libmbedtls-dev \
    libacl1-dev \
    libbz2-dev \
    liblzma-dev \
    liblz4-dev \
    libzstd-dev \
    lzop \
    pkg-config \
    zlib1g-dev

WORKDIR /app

COPY repo/ /app/

ENV BS=cmake
ENV CRYPTO=mbedtls
ENV MAKE_ARGS=-j4
ENV SKIP_OPEN_FD_ERR_TEST=1
ENV CTEST_OUTPUT_ON_FAILURE=ON

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
