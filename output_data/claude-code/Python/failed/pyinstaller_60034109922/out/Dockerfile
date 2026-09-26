FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=1
ENV PYINSTALLER_STRICT_UNPACK_MODE=1
ENV PYINSTALLER_STRICT_COLLECT_MODE=1
ENV PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1
ENV PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1
ENV PYTHONWARNDEFAULTENCODING=true

# Install basic tools and Python 3.11 with deadsnakes PPA
RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update -qq && \
    apt-get upgrade -qq && \
    apt-get install -qq --no-install-recommends \
      python3.11 \
      python3.11-dev \
      python3.11-distutils \
      python3-pip \
      python3-setuptools \
      wget \
      curl \
      git \
      build-essential \
      pkg-config \
      libcmocka-dev \
      libxml2-dev libxslt1-dev gfortran libatlas-base-dev \
      libespeak1 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 \
      libxkbcommon-x11-0 libxcb-icccm4 libxcb1 openssl \
      libxcb-randr0-dev libxcb-xtest0-dev libxcb-xinerama0-dev \
      libxcb-shape0-dev libxcb-xkb-dev libxcb-cursor0 xvfb \
      libopengl0 libegl1 \
      libpulse0 libpulse-mainloop-glib0 \
      gstreamer1.0-plugins-base libgstreamer-gl1.0-0 \
      libgirepository1.0-dev libgirepository-2.0-dev libcairo2-dev \
      gir1.2-girepository-2.0 gir1.2-girepository-3.0 gir1.2-gtk-3.0 \
      libfuse2 \
      locales

# Make Python 3.11 the default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install and enable additional locales
RUN locale-gen \
    en_US.UTF-8 \
    en_US \
    sl_SI.UTF-8 \
    sl_SI \
    cs_CZ.UTF-8

# Download AppImage tool
RUN wget https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage \
    -O /root/appimagetool-x86_64.AppImage && \
    chmod a+x /root/appimagetool-x86_64.AppImage

WORKDIR /app
COPY repo/ /app/

# Update pip and install hatchling
RUN python -m pip install --upgrade pip hatchling

# Compile bootloader with gnu90 C standard
RUN cd bootloader && CC="gcc -std=gnu90" python waf --tests all

# Compile bootloader with c99 ISO C standard (pedantic mode)
RUN cd bootloader && CC="gcc -std=c99 -pedantic" python waf --tests all

# Check bootloader with --static-zlib option
RUN cd bootloader && python waf --static-zlib --tests all

# Compile bootloader normally
RUN cd bootloader && python waf --tests all

# Download dependencies
RUN python -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl

# Build wheels
RUN sh release/build-wheels

# Install PyInstaller
RUN python -m pip install --no-index --find-links=dist pyinstaller[completion]

# Verify installation
RUN python -m PyInstaller -h

# Install test dependencies (base tools)
RUN python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt

# Install test dependencies (tools and libraries)
RUN python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-libraries.txt

# Work around potentially broken setuptools upgrade
COPY setuptools_fix.py /tmp/setuptools_fix.py
RUN python /tmp/setuptools_fix.py

# Install hooksample
RUN python -m pip install "https://github.com/pyinstaller/hooksample/archive/v4.0rc1.zip"

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
