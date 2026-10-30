FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TYPE=Release

# Install base dependencies and build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    devscripts \
    equivs \
    software-properties-common \
    language-pack-en \
    language-pack-sv \
    pkg-config \
    dbus \
    libarchive-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libdrm-dev \
    libelf-dev \
    libexif-dev \
    libgdk-pixbuf-2.0-dev \
    libglew-dev \
    libgtk-3-dev \
    libjs-highlight.js \
    libjs-mathjax \
    liblz4-dev \
    liblzma-dev \
    libpango1.0-dev \
    libshp-dev \
    libsqlite3-dev \
    libssl-dev \
    libtinyxml-dev \
    libudev-dev \
    libunarr-dev \
    libusb-1.0-0-dev \
    libwxgtk3.0-gtk3-dev \
    libwxgtk-webview3.0-gtk3-dev \
    libwxsvg-dev \
    lsb-release \
    portaudio19-dev \
    python-is-python3 \
    python3-dbus \
    python3-gi \
    rapidjson-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the repository
COPY repo/ /app/

WORKDIR /app

# Build the project
RUN mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} .. && \
    cmake --build . --config ${BUILD_TYPE}

# Prepare test command
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
