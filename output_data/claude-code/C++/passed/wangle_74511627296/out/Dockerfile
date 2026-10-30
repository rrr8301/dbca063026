FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    build-essential \
    cmake \
    ninja-build \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /app

COPY repo /app

RUN apt-get update && python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive wangle && \
    python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
