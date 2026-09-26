FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    curl \
    git \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'root ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /app
COPY repo/ /app/

RUN apt-get update

RUN python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive proxygen && \
    python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
