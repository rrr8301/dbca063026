FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SUFFIX=linux-i386

RUN apt-get update && apt-get install -y \
  automake \
  autoconf \
  libtool \
  gcc-multilib \
  g++-multilib \
  make \
  pkg-config \
  git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN git config --system core.autocrlf false && \
  git submodule update --init --recursive

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
