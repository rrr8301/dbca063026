FROM python:3.11-slim

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables for PyInstaller and Python
ENV FORCE_COLOR=1 \
    PYINSTALLER_STRICT_UNPACK_MODE=1 \
    PYINSTALLER_STRICT_COLLECT_MODE=1 \
    PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 \
    PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 \
    PYTHONWARNDEFAULTENCODING=true \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies (Python 3.11 already included in base image)
RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends \
    git \
    gcc \
    g++ \
    make \
    wget \
    libcmocka-dev \
    libxml2-dev \
    libxslt1-dev \
    gfortran \
    libatlas-base-dev \
    libespeak1 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb1 \
    openssl \
    libxcb-randr0-dev \
    libxcb-xtest0-dev \
    libxcb-xinerama0-dev \
    libxcb-shape0-dev \
    libxcb-xkb-dev \
    libxcb-cursor0 \
    xvfb \
    libopengl0 \
    libegl1 \
    libpulse0 \
    libpulse-mainloop-glib0 \
    gstreamer1.0-plugins-base \
    libgstreamer-gl1.0-0 \
    libgirepository1.0-dev \
    libgirepository-2.0-dev \
    libcairo2-dev \
    gir1.2-girepository-2.0 \
    gir1.2-girepository-3.0 \
    gir1.2-gtk-3.0 \
    libfuse2 \
    locales && \
    rm -rf /var/lib/apt/lists/*

# Generate required locales
RUN locale-gen en_US.UTF-8 && \
    locale-gen en_US && \
    locale-gen sl_SI.UTF-8 && \
    locale-gen sl_SI && \
    locale-gen cs_CZ.UTF-8

# Set default locale
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Upgrade pip and install hatchling
RUN python3.11 -m pip install --upgrade pip hatchling

# Download AppImage tool
RUN wget \
    https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage \
    -O /root/appimagetool-x86_64.AppImage && \
    chmod a+x /root/appimagetool-x86_64.AppImage

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]