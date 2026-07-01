FROM ubuntu:22.04

# Set timezone to avoid interactive prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update package lists
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    g++ \
    git \
    curl \
    wget \
    pkg-config \
    ocl-icd-opencl-dev \
    opencl-headers \
    vulkan-tools \
    libvulkan-dev \
    libopus-dev \
    libopusfile-dev \
    libopencv-dev \
    libjpeg-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository (assumes build context includes the repo)
COPY . /workspace/

# Copy and make run script executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]