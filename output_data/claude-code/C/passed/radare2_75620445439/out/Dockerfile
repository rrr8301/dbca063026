FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    python3 \
    python3-pip \
    wget \
    gperf \
    file \
    libfuse-dev \
    cabextract \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN python3 -m pip install --upgrade pip && \
    pip3 install --user r2pipe wheel

ENV CFLAGS="-O2 -Wno-unused-result"
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN cd /app && sys/install.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
