FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libopencv-dev \
    opencl-headers \
    ocl-icd-libopencl1 \
    libvulkan-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libaudiofile-dev \
    libsndfile1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
