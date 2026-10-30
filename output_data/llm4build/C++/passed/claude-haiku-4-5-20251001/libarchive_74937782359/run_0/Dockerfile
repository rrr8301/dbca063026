FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update apt cache
RUN apt-get update

# Install dependencies
RUN apt-get install -y \
    autoconf \
    automake \
    build-essential \
    cmake \
    git \
    libssl-dev \
    nettle-dev \
    libmbedtls-dev \
    libacl1-dev \
    libbz2-dev \
    liblzma-dev \
    liblz4-dev \
    libzstd-dev \
    lzop \
    pkg-config \
    zlib1g-dev

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]