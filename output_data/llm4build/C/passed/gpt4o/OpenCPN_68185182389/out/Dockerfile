FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set non-interactive frontend for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    g++ \
    curl \
    wget \
    pkg-config \
    libgtk-3-dev \
    libgl1-mesa-dev \
    libwxgtk3.0-gtk3-dev \
    libglew-dev \
    gettext \
    libssl-dev \
    libcurl4-openssl-dev \
    libsqlite3-dev \
    libusb-1.0-0-dev \
    libudev-dev \
    libasound2-dev \
    libjack-dev \
    portaudio19-dev \
    rapidjson-dev \
    equivs \
    libtool \
    autoconf \
    automake \
    bubblewrap \
    dictionaries-common \
    fonts-mathjax \
    glib-networking \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    hunspell-en-us \
    libaa1 \
    libaom3 \
    libarchive-dev \
    libaspell15 \
    libasyncns0 \
    libavc1394-0 \
    libavcodec58 \
    libavformat58 \
    libavutil56 \
    libbluray2 \
    libbz2-dev \
    libcaca0 \
    libcdparanoia0 \
    libchromaprint1 \
    libcodec2-1.0 \
    libcxx-serial-dev \
    libcxx-serial1 \
    libdav1d5 \
    libdrm-dev \
    libdv4 \
    libelf-dev \
    libenchant-2-2 \
    libevdev2 \
    libexif-dev \
    libexif12 \
    libflac8 \
    libgme0 \
    libgpm2 \
    libgsm1 \
    libgstreamer-gl1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer-plugins-good1.0-0 \
    libgudev-1.0-0 \
    libhunspell-1.7-0 \
    libhyphen0 \
    libiec61883-0 \
    libjavascriptcoregtk-4.0-18 \
    libjs-highlight.js \
    libjs-mathjax \
    liblz4-dev \
    libmanette-0.2-0 \
    libmfx1 \
    libmp3lame0 \
    libmpg123-0 \
    libnorm1 \
    libnuma1 \
    libogg0 \
    libopenjp2-7 \
    libopenmpt0 \
    libopus0 \
    liborc-0.4-0 \
    libpciaccess-dev \
    libpgm-5.3-0 \
    libproxy1v5 \
    libpulse0 \
    librabbitmq4 \
    libraw1394-11 \
    libsecret-1-0 \
    libsecret-common \
    libshine3 \
    libshout3 \
    libshp-dev \
    libshp2 \
    libslang2 \
    libsnappy1v5 \
    libsndfile1 \
    libsodium23 \
    libsoup2.4-1 \
    libsoup2.4-common \
    libsoxr0 \
    libspeex1 \
    libsrt1.4-gnutls \
    libssh-gcrypt-4 \
    libswresample3 \
    libswscale5 \
    libtag1v5 \
    libtag1v5-vanilla \
    libtext-iconv-perl \
    libtheora0 \
    libtinyxml-dev \
    libtinyxml2.6.2v5 \
    libtwolame0 \
    libudfread0 \
    libunarr-dev \
    libunarr1 \
    libv4l-0 \
    libv4lconvert0 \
    libva-drm2 \
    libva-x11-2 \
    libva2 \
    libvdpau1 \
    libvisual-0.4-0 \
    libvorbis0a \
    libvorbisenc2 \
    libvorbisfile3 \
    libvpx7 \
    libwavpack1 \
    libwebkit2gtk-4.0-37 \
    libwebpdemux2 \
    libwebpmux3 \
    libwoff1 \
    libwxgtk-webview3.0-gtk3-0v5 \
    libwxgtk-webview3.0-gtk3-dev \
    libwxsvg-dev \
    libwxsvg3 \
    libx264-163 \
    libx265-199 \
    libxslt1.1 \
    libxvidcore4 \
    libzmq5 \
    libzvbi-common \
    libzvbi0 \
    ocl-icd-libopencl1 \
    python-is-python3 \
    xdg-dbus-proxy \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Ensure pre-build script is executable
RUN chmod +x /app/ci/github-pre-build.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]