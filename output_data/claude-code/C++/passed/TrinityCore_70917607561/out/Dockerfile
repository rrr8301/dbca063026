FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq \
    build-essential \
    cmake \
    ninja-build \
    git \
    wget \
    clang-17 \
    ccache \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-locale-dev \
    libboost-program-options-dev \
    libboost-regex-dev \
    libboost-thread-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libbz2-dev \
    libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
