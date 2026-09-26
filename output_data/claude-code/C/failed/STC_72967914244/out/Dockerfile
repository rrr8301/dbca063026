FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    python3 \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install meson and ninja via pip
RUN python3 -m pip install --upgrade pip meson ninja

# Set clang as the default compiler
ENV CC=clang
ENV CXX=clang++

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
