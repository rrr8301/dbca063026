FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CXX=g++
ENV CXXFLAGS="-Werror -Wall -Wpedantic"
ENV RUSTFLAGS="--cfg deny_warnings -Dwarnings"

RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --component rust-src

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
