FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables for the build
ENV NO_AT_BRIDGE=1 \
    OPENBLAS_NUM_THREADS=1 \
    PYTHONFAULTHANDLER=1 \
    DEBIAN_FRONTEND=noninteractive

# Install OS dependencies
RUN echo 'Acquire::Retries "3";' | tee /etc/apt/apt.conf.d/80-retries && \
    apt-get update -yy && \
    apt-get install -yy --no-install-recommends \
    build-essential \
    ccache \
    cm-super \
    curl \
    dvipng \
    fonts-freefont-otf \
    fonts-noto-cjk \
    fonts-wqy-zenhei \
    gdb \
    gir1.2-gtk-3.0 \
    gir1.2-gtk-4.0 \
    git \
    graphviz \
    inkscape \
    language-pack-de \
    lcov \
    libcairo2 \
    libcairo2-dev \
    libffi-dev \
    libgeos-dev \
    libgirepository-2.0-dev \
    libnotify4 \
    libsdl2-2.0-0 \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    lmodern \
    ninja-build \
    pkg-config \
    poppler-utils \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    qtbase5-dev \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-latex-recommended \
    texlive-luatex \
    texlive-pictures \
    texlive-xetex \
    ffmpeg \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Set up Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Upgrade pip, setuptools, wheel
RUN python -m pip install --upgrade pip setuptools wheel

# Install Python dependencies
RUN python -m pip install --upgrade \
    'contourpy>=1.0.1' \
    cycler \
    fonttools \
    kiwisolver \
    importlib_resources \
    packaging \
    pillow \
    'pyparsing!=3.1.0' \
    python-dateutil \
    setuptools-scm \
    'meson-python>=0.13.1' \
    'pybind11>=2.13.2'

# Install testing dependencies
RUN python -m pip install --upgrade \
    pytest \
    pytest-xdist \
    pytest-timeout \
    pytest-cov

# Install sphinx
RUN python -m pip install --upgrade 'sphinx!=6.1.2'

# Install GUI dependencies
RUN python -m pip install --upgrade pycairo 'cairocffi>=0.8' 'PyGObject' && \
    python -c 'import gi; gi.require_version("Gtk", "4.0"); from gi.repository import Gtk' && \
    echo 'PyGObject 4 is available' || echo 'PyGObject 4 is not available'

RUN python -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk' && \
    echo 'PyGObject 3 is available' || echo 'PyGObject 3 is not available' || true

RUN python -m pip install --upgrade --only-binary :all: pyqt5 && \
    python -c 'import PyQt5.QtCore' && \
    echo 'PyQt5 is available' || echo 'PyQt5 is not available' || true

RUN python -m pip install --upgrade --only-binary :all: pyqt6 && \
    python -c 'import PyQt6.QtCore' && \
    echo 'PyQt6 is available' || echo 'PyQt6 is not available' || true

RUN python -m pip install --upgrade --only-binary :all: pyside6 && \
    python -c 'import PySide6.QtCore' && \
    echo 'PySide6 is available' || echo 'PySide6 is not available' || true

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]