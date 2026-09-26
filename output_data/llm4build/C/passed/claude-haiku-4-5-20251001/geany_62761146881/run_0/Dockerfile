FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --assume-yes --no-install-recommends \
    git \
    build-essential \
    ccache \
    gettext \
    autopoint \
    libtool \
    autoconf \
    automake \
    libgtk-3-dev \
    doxygen \
    python3-docutils \
    python3-lxml \
    rst2pdf \
    meson \
    ninja-build \
    pkg-config \
    make && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CFLAGS="-g -O2 -Werror=pointer-arith -Werror=implicit-function-declaration"
ENV CCACHE_DIR=/workspace/.ccache
ENV CCACHE_COMPRESS=true
ENV CCACHE_MAXSIZE=1G
ENV PYTHON=python3
ENV JOBS=2
ENV DEBUG=0
ENV CC="ccache gcc"
ENV CXX="ccache g++"

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]