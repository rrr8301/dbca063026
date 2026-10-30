FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-pip \
    clang \
    ninja-build \
    pkg-config \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install meson

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
