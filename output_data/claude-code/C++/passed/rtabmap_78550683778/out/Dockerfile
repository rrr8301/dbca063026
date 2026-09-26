FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TYPE=Release

# Install system dependencies
RUN apt-get update && \
    apt-get -y install \
        libopencv-dev \
        libpcl-dev \
        git \
        cmake \
        software-properties-common \
        libyaml-cpp-dev \
        libunwind-dev \
        libceres-dev \
        python3 \
        python3-pip \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN python3 -m pip install --upgrade pip && \
    pip install numpy pybind11

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Create build directory and configure CMake
RUN cmake -B /app/build \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DPython3_EXECUTABLE=$(which python3) \
    -Dpybind11_DIR=$(python3 -m pybind11 --cmakedir) \
    -DWITH_CERES=ON \
    -DWITH_PYTHON=ON

# Build the project
RUN cmake --build /app/build --config ${BUILD_TYPE}

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
