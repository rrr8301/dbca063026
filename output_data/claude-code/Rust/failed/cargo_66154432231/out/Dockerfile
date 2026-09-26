FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
      build-essential \
      curl \
      git \
      pkg-config \
      libssl-dev \
      libsecret-1-0 \
      libsecret-1-dev \
      lldb \
      gcc-multilib

WORKDIR /app
COPY repo/ /app/

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env && \
    rustup update stable && \
    rustup default stable && \
    rustup target add wasm32-unknown-unknown && \
    rustup component add rustfmt || echo "rustfmt not available"

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
