FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV BUILD_TYPE=Debug

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    wget \
    libpng-dev \
    locales \
    ca-certificates \
    python3 \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Generate German locale
RUN locale-gen de_DE.UTF-8 && update-locale LANG=de_DE.UTF-8

# Install Qt6 6.9.0
RUN mkdir -p /opt/qt && cd /opt/qt && \
    wget -q https://download.qt.io/official_releases/qt/6.9/6.9.0/single/qt-everywhere-src-6.9.0.tar.xz && \
    tar -xf qt-everywhere-src-6.9.0.tar.xz && \
    cd qt-everywhere-src-6.9.0 && \
    ./configure -prefix /opt/qt/6.9.0 -release -opensource -confirm-license -skip qtwebengine -nomake examples -nomake tests && \
    cmake --build . -j$(nproc) && \
    cmake --install . && \
    cd /opt/qt && rm -rf qt-everywhere-src-6.9.0 qt-everywhere-src-6.9.0.tar.xz

ENV QT_ROOT_DIR=/opt/qt/6.9.0
ENV PATH=$QT_ROOT_DIR/bin:$PATH
ENV LD_LIBRARY_PATH=$QT_ROOT_DIR/lib:$LD_LIBRARY_PATH
ENV CMAKE_PREFIX_PATH=$QT_ROOT_DIR:$CMAKE_PREFIX_PATH

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]