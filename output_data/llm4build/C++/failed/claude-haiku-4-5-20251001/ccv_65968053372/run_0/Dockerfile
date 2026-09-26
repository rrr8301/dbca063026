FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    make \
    clang \
    libpng-dev \
    libjpeg-dev \
    libatlas-base-dev \
    libblas-dev \
    libgsl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository (assumes repo is available in build context)
COPY . /workspace/

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]