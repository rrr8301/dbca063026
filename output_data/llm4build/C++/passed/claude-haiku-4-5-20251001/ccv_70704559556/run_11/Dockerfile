FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    gcc \
    autoconf \
    automake \
    libtool \
    make \
    libjpeg-dev \
    libpng-dev \
    libfftw3-dev \
    libpthread-stubs0-dev \
    libblas-dev \
    liblapack-dev \
    libopenblas-dev \
    libopenblas0-pthread \
    gfortran \
    wget \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy entire repository
COPY . /workspace/

# Make run.sh executable
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]