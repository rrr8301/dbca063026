FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV QTEST_COLOR=1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    zlib1g-dev \
    libjpeg-dev \
    libgnutls28-dev \
    libssl-dev \
    libtiff-tools \
    ghostscript \
    zsh \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
