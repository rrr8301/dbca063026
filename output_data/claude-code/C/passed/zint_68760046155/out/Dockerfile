FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TYPE=Release

RUN apt-get update && apt-get install -y \
    cmake \
    make \
    gcc \
    g++ \
    git \
    libpng-dev \
    qt5-qmake \
    qtbase5-dev \
    qttools5-dev \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen de_DE.UTF-8 && update-locale

WORKDIR /app

COPY repo/ /app/

RUN git config --global --add safe.directory /app

RUN git clone --depth=1 https://github.com/gs1/gs1-syntax-engine /tmp/gs1-syntax-engine && \
    cd /tmp/gs1-syntax-engine/src/c-lib && \
    make lib && \
    make install && \
    ldconfig

RUN cmake -E make_directory build

WORKDIR /app/build

RUN cmake /app \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DZINT_TEST=ON \
    -DZINT_STATIC=ON

RUN cmake --build . -j8 --config $BUILD_TYPE

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
