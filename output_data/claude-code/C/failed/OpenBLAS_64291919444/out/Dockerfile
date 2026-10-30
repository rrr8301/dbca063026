FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    ccache \
    clang \
    gfortran \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=ON \
          -DBUILD_STATIC_LIBS=ON \
          -DDYNAMIC_ARCH=ON \
          -DUSE_THREAD=ON \
          -DNUM_THREADS=64 \
          -DTARGET=CORE2 \
          -DCMAKE_C_COMPILER=clang \
          -DCMAKE_Fortran_COMPILER=gfortran \
          -DCMAKE_C_COMPILER_LAUNCHER=ccache \
          -DCMAKE_Fortran_COMPILER_LAUNCHER=ccache \
          .. && \
    cmake --build .

COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
