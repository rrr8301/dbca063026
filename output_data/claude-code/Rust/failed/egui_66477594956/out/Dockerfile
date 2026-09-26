FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTFLAGS=-D\ warnings
ENV RUSTDOCFLAGS=-D\ warnings
ENV XDG_RUNTIME_DIR=/tmp

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libssl-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    libgtk-3-dev \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

RUN git lfs install

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.92.0

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

RUN git lfs pull

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
