FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    ruby \
    ruby-dev \
    bundler \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN bundle install

ENV MRUBY_CONFIG=ci/gcc-clang
ENV CC=clang
ENV CXX=clang++
ENV LD=clang

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
