FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -qq && apt-get install -y -qq \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    libboost-program-options-dev \
    libboost-serialization-dev \
    libboost-test-dev \
    libeigen3-dev \
    libflann-dev \
    libtriangle-dev \
    libyaml-cpp-dev

WORKDIR /app

COPY repo/ /app/

RUN cd /app && git submodule update --init --recursive

RUN python3 -m pip install --upgrade pip && \
    pip install pytest

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
