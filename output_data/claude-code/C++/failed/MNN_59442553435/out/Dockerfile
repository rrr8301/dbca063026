FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ocl-icd-opencl-dev \
    libvulkan-dev \
    libvulkan1 \
    vulkan-tools \
    libopencv-dev \
    libpng-dev \
    libprotobuf-dev \
    protobuf-compiler \
    python3 \
    python3-dev \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
