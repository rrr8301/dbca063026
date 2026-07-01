FROM ubuntu:22.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build tools and dependencies
RUN apt-get -o Acquire::Retries=5 update && \
    apt-get install -o Acquire::Retries=5 -y \
    build-essential \
    autoconf \
    automake \
    git \
    sudo \
    cpanminus \
    libtool-bin \
    libapr1-dev \
    libaprutil1-dev \
    liblua5.3-dev \
    libbrotli-dev \
    libcurl4-openssl-dev \
    libnghttp2-dev \
    libjansson-dev \
    libpcre2-dev \
    gdb \
    perl-doc \
    libsasl2-dev \
    curl \
    python3-pytest \
    nghttp2-client \
    python3-cryptography \
    python3-requests \
    python3-multipart \
    python3-filelock \
    python3-websockets && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]