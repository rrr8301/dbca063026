FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        git \
        libmbedtls-dev \
        python3 \
        pkg-config

WORKDIR /app

COPY repo/ /app/

RUN mkdir -p build && \
    cd build && \
    cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON && \
    cmake --build .

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
