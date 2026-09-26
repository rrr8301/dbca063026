FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libcppunit-dev \
    libutfcpp-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN cmake -B/app/build \
    -DBUILD_SHARED_LIBS=ON \
    -DVISIBILITY_HIDDEN=ON \
    -DBUILD_TESTING=ON \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_BINDINGS=ON \
    -DCMAKE_BUILD_TYPE=Release

RUN cmake --build /app/build --config Release --parallel

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
