FROM ubuntu:24.04

# Set timezone noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    gcc \
    g++ \
    make \
    clang \
    meson \
    ninja-build \
    libglib2.0-dev \
    attr \
    gettext \
    bison \
    dbus \
    gtk-doc-tools \
    libfuse3-dev \
    fuse3 \
    ostree \
    libostree-dev \
    libarchive-dev \
    libzstd-dev \
    libcap-dev \
    libattr1-dev \
    libdw-dev \
    libelf-dev \
    python3-pyparsing \
    libjson-glib-dev \
    shared-mime-info \
    desktop-file-utils \
    libpolkit-agent-1-dev \
    libpolkit-gobject-1-dev \
    policykit-1 \
    libseccomp-dev \
    libcurl4-openssl-dev \
    libsystemd-dev \
    libxml2-utils \
    libgpgme11-dev \
    gobject-introspection \
    libgirepository1.0-dev \
    libappstream-dev \
    libdconf-dev \
    socat \
    libdbus-1-dev \
    e2fslibs-dev \
    bubblewrap \
    xdg-dbus-proxy \
    libyaml-dev \
    libstemmer-dev \
    gperf \
    itstool \
    libmalcontent-0-dev \
    libxau-dev \
    libgdk-pixbuf2.0-dev \
    openssl \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Create directory needed by tests
RUN mkdir -p /tmp/flatpak-com.example.App-OwnedByRoot

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]