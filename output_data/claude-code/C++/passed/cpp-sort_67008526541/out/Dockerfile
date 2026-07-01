FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++-9 \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setup mold linker
RUN curl -L https://github.com/rui314/mold/releases/download/v2.0.0/mold-2.0.0-x86_64-linux.tar.gz | tar xzf - && \
    cp mold-2.0.0-x86_64-linux/bin/mold /usr/local/bin/ && \
    cp mold-2.0.0-x86_64-linux/lib/mold/mold-wrapper.so /usr/local/lib/ && \
    rm -rf mold-2.0.0-x86_64-linux

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
