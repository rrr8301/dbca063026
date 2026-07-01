FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    libssl-dev \
    unixodbc-dev \
    libmysqlclient-dev \
    redis-server \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN cmake -S. -Bcmake-build -GNinja -DENABLE_PDF=OFF -DENABLE_TESTS=ON

RUN cmake --build cmake-build --parallel $(nproc)

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
