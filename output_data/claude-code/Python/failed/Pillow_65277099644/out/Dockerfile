FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV GHA_PYTHON_VERSION=3.12

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-dev \
    python3-pip \
    build-essential \
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
    git \
    libegl1 \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxkbcommon-x11-0 \
    xvfb \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3.12 -m pip install --break-system-packages coverage defusedxml ipython olefile pytest pytest-cov pytest-timeout pyroma pytest-reverse

RUN python3.12 -m pip install --break-system-packages --only-binary=:all: numpy || true
RUN python3.12 -m pip install --break-system-packages --only-binary=:all: pyarrow || true
RUN python3.12 -m pip install --break-system-packages --only-binary=:all: pyqt6 || true

WORKDIR /app
COPY repo/ /app/
COPY install_deps.sh /install_deps.sh
RUN chmod +x /install_deps.sh && /install_deps.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
