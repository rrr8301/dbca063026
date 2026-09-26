FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --assume-yes --no-install-recommends \
      autoconf \
      automake \
      build-essential \
      ccache \
      gettext autopoint \
      gcc \
      g++ \
      libtool \
      libgtk-3-dev \
      doxygen \
      make \
      python3-docutils \
      python3-lxml \
      rst2pdf

# Set environment variables for build
ENV CFLAGS="-g -O2 -Werror=pointer-arith -Werror=implicit-function-declaration" \
    CCACHE_DIR="/app/.ccache" \
    CCACHE_COMPRESS="true" \
    CCACHE_MAXSIZE="1G" \
    PYTHON="python3" \
    JOBS="2" \
    DEBUG="0" \
    CONFIGURE_FLAGS="--enable-binreloc=no" \
    CC="ccache gcc" \
    CXX="ccache g++" \
    NOCONFIGURE="1"

WORKDIR /app

COPY repo/ /app/

# Setup build directory
RUN ./autogen.sh && \
    mkdir _build && \
    cd _build && \
    ../configure $CONFIGURE_FLAGS

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
