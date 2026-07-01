FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CTEST_OUTPUT_ON_FAILURE=ON
ENV CTEST_PARALLEL_LEVEL=2
ENV IGL_NUM_THREADS=1

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ccache \
    libblas-dev \
    libglu1-mesa-dev \
    liblapack-dev \
    xorg-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN ccache --max-size=1.0G && \
    ccache -V && \
    ccache --show-stats && \
    ccache --zero-stats

RUN mkdir -p build && \
    cd build && \
    cmake .. \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIBIGL_USE_STATIC_LIBRARY=ON \
    -DLIBIGL_BUILD_TUTORIALS=ON \
    -DLIBIGL_GLFW_TESTS=OFF \
    -DLIBIGL_BUILD_TESTS=ON \
    -DLIBIGL_COPYLEFT_CGAL=ON

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
