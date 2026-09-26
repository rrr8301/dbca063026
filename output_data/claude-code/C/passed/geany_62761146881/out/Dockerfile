FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CFLAGS="-g -O2 -Werror=pointer-arith -Werror=implicit-function-declaration"
ENV CCACHE_DIR="/app/.ccache"
ENV CCACHE_COMPRESS=true
ENV CCACHE_MAXSIZE=1G
ENV PYTHON=python3
ENV JOBS=2
ENV DEBUG=0
ENV CC="ccache gcc"
ENV CXX="ccache g++"

RUN apt-get update -qq && \
    apt-get install --assume-yes --no-install-recommends \
        ccache \
        gettext autopoint \
        libtool \
        libgtk-3-dev \
        doxygen \
        python3-docutils \
        python3-lxml \
        rst2pdf \
        meson \
        ninja-build \
        gcc \
        g++ \
        pkg-config

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
