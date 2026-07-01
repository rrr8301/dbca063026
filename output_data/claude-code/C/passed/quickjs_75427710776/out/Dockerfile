FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    ninja-build \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install meson

WORKDIR /app

COPY repo/ /app/

RUN pip3 install meson ninja

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
