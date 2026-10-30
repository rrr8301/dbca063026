FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    COVERAGE_CORE=sysmon \
    FORCE_COLOR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONOPTIMIZE=1 \
    REVERSE="--reverse"

RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    build-essential \
    git \
    curl \
    wget \
    pkg-config \
    libfreetype6-dev \
    liblcms2-dev \
    libtiff-dev \
    python3-tk \
    ghostscript \
    libjpeg-turbo8-dev \
    libopenjp2-7-dev \
    cmake \
    meson \
    imagemagick \
    libharfbuzz-dev \
    libfribidi-dev \
    sway \
    wl-clipboard \
    libopenblas-dev \
    nasm \
    libegl1 \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxkbcommon-x11-0 \
    && rm -rf /var/lib/apt/lists/*

RUN python3.12 -m ensurepip --upgrade
RUN python3.12 -m pip install --upgrade setuptools

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

WORKDIR /app
COPY repo /app/

RUN python3 -m pip install --upgrade pip wheel
RUN python3 -m pip install coverage defusedxml ipython olefile pyroma
RUN python3 -m pip install -U pytest pytest-cov pytest-timeout pytest-reverse
RUN python3 -m pip install --only-binary=:all: numpy || true
RUN python3 -m pip install --only-binary=:all: pyarrow || true
RUN python3 -m pip install pyqt6 || true

WORKDIR /app/depends
RUN chmod +x install_webp.sh && ./install_webp.sh
RUN chmod +x install_imagequant.sh && ./install_imagequant.sh
RUN chmod +x install_raqm.sh && ./install_raqm.sh
RUN chmod +x install_libavif.sh && ./install_libavif.sh
RUN chmod +x install_extra_test_images.sh && ./install_extra_test_images.sh

WORKDIR /app
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
