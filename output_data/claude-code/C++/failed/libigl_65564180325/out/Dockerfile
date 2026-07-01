FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV IGL_NUM_THREADS=1

# Install dependencies
RUN apt-get update && apt-get install -y \
    libblas-dev \
    libglu1-mesa-dev \
    liblapack-dev \
    xorg-dev \
    ccache \
    cmake \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Setup ccache
RUN mkdir -p ~/.ccache && ccache --max-size=1.0G

# Configure
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

# Build
RUN cd build && make -j2 && ccache --show-stats

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
