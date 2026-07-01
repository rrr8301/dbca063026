FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TYPE=Release
ENV wxGTK_VERSION=3

WORKDIR /app

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    devscripts \
    equivs \
    software-properties-common \
    language-pack-en \
    language-pack-sv \
    dbus \
    libarchive-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libcxx-serial-dev \
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
    libusb-1.0-0-dev \
    libwxsvg-dev \
    libwxgtk3.2-dev \
    libwxgtk-webview3.2-dev \
    lsb-release \
    portaudio19-dev \
    python3-dbus \
    python-is-python3 \
    rapidjson-dev \
    googletest \
    && rm -rf /var/lib/apt/lists/*

# Copy repo
COPY repo/ /app/

# Copy and run the build script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
