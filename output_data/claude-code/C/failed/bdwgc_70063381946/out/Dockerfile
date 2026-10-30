FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    clang \
    git \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN cmake -B build \
    -S . \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_C_COMPILER=clang \
    -DGC_BUILD_SHARED_LIBS=on \
    -Denable_werror=on \
    -Werror=dev \
    -Denable_gc_assertions=on \
    -Denable_large_config=on \
    -Denable_redirect_malloc=on \
    -Denable_rwlock=on \
    -DCFLAGS_EXTRA=-DIGNORE_FREE

RUN cmake --build build --config Debug --verbose --parallel

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
