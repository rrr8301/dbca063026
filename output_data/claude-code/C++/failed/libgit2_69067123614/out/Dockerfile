FROM ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        clang \
        clang-18 \
        cmake \
        curl \
        gcc \
        git \
        krb5-user \
        libclang-rt-18-dev \
        libcurl4-gnutls-dev \
        libgcrypt20-dev \
        libhttp-parser-dev \
        libkrb5-dev \
        libpcre3-dev \
        libssh2-1-dev \
        libssl-dev \
        libz-dev \
        llvm-18 \
        make \
        ninja-build \
        openjdk-8-jre-headless \
        openssh-server \
        openssl \
        pkgconf \
        python3 \
        valgrind && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo /app/

ENV CC=clang
ENV CFLAGS=-fsanitize=undefined,nullability\ -fno-sanitize-recover=undefined,nullability\ -fsanitize-blacklist=/app/script/sanitizers.supp\ -fno-optimize-sibling-calls\ -fno-omit-frame-pointer
ENV CMAKE_OPTIONS=-DCMAKE_PREFIX_PATH=/usr/local\ -DUSE_HTTPS=OpenSSL\ -DUSE_SHA1=HTTPS\ -DREGEX_BACKEND=pcre\ -DDEPRECATE_HARD=ON\ -DUSE_BUNDLED_ZLIB=ON\ -DUSE_SSH=ON
ENV CMAKE_GENERATOR=Ninja
ENV SKIP_SSH_TESTS=true
ENV SKIP_NEGOTIATE_TESTS=true
ENV ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-18
ENV UBSAN_OPTIONS=print_stacktrace=1
ENV BUILD_PATH=$PATH

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
