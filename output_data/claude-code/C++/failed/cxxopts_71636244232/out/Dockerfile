FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    clang \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++
RUN cmake --build ./build --config Release

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
