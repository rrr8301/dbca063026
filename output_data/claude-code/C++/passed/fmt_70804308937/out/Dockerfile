FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    cmake \
    build-essential \
    clang-11 \
    locales-all \
    software-properties-common \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

ENV TZ=Europe/Kyiv

RUN mkdir -p /etc/apt && \
    mirrors=/etc/apt/mirrors.txt && \
    printf 'http://azure.archive.ubuntu.com/ubuntu\tpriority:1\n' > $mirrors && \
    curl http://mirrors.ubuntu.com/mirrors.txt >> $mirrors 2>/dev/null || true && \
    sed -i "s~http://azure.archive.ubuntu.com/ubuntu/~mirror+file:$mirrors~" /etc/apt/sources.list

WORKDIR /app

COPY repo /app/

RUN mkdir -p /build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
