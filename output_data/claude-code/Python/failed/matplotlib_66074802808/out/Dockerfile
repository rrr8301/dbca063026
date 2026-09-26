FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    NO_AT_BRIDGE=1 \
    OPENBLAS_NUM_THREADS=1 \
    PYTHONFAULTHANDLER=1

WORKDIR /app

# Install OS dependencies
RUN apt-get update -yy && \
    apt-get install -yy --no-install-recommends \
      build-essential \
      ccache \
      cm-super \
      dvipng \
      fonts-freefont-otf \
      fonts-noto-cjk \
      fonts-wqy-zenhei \
      gdb \
      gir1.2-gtk-3.0 \
      gir1.2-gtk-4.0 \
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
      libxkbcommon-x11-0 \
      libxcb-cursor0 \
      libxcb-icccm4 \
      libxcb-image0 \
      libxcb-keysyms1 \
      libxcb-randr0 \
      libxcb-render-util0 \
      libxcb-xinerama0 \
      lmodern \
      ninja-build \
      pkg-config \
      python3-pip \
      python3.12 \
      python3.12-dev \
      qtbase5-dev \
      texlive-fonts-recommended \
      texlive-latex-base \
      texlive-latex-extra \
      texlive-latex-recommended \
      texlive-luatex \
      texlive-pictures \
      texlive-xetex \
      ffmpeg \
      poppler-utils \
      git \
      wget \
      ca-certificates

# Set Python 3.12 as the default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

COPY repo/ /app/

# Install Python dependencies
RUN python -m pip install --break-system-packages --upgrade pip setuptools wheel && \
    python -m pip install --break-system-packages --upgrade --prefer-binary \
      --group build --group test && \
    python -m pip install --break-system-packages --upgrade sphinx!=6.1.2 && \
    python -m pip install --break-system-packages --upgrade pycairo 'cairocffi>=0.8' 'PyGObject<3.52.0' && \
    (python -c 'import gi; gi.require_version("Gtk", "4.0"); from gi.repository import Gtk' && \
     echo 'PyGObject 4 is available' || echo 'PyGObject 4 is not available') && \
    (python -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk' && \
     echo 'PyGObject 3 is available' || echo 'PyGObject 3 is not available') && \
    python -mpip install --break-system-packages --upgrade --only-binary :all: pyqt5 && \
    (python -c 'import PyQt5.QtCore' && echo 'PyQt5 is available' || echo 'PyQt5 is not available') && \
    python -mpip install --break-system-packages --upgrade --only-binary :all: pyqt6 && \
    (python -c 'import PyQt6.QtCore' && echo 'PyQt6 is available' || echo 'PyQt6 is not available') && \
    python -mpip install --break-system-packages --upgrade --only-binary :all: pyside6 && \
    (python -c 'import PySide6.QtCore' && echo 'PySide6 is available' || echo 'PySide6 is not available') || true

# Install Matplotlib
RUN cd /app && \
    ccache -s && \
    git describe && \
    export CPPFLAGS='--coverage -fprofile-abs-path' && \
    python -m pip install --break-system-packages --verbose \
      --config-settings=setup-args="-DrcParams-backend=Agg" \
      --editable .[dev] && \
    unset CPPFLAGS

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
