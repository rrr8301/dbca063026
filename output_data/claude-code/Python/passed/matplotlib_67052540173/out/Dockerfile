FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NO_AT_BRIDGE=1
ENV OPENBLAS_NUM_THREADS=1
ENV PYTHONFAULTHANDLER=1

RUN apt-get update -yy && \
    apt-get install -yy --no-install-recommends \
      curl \
      git \
      python3.12 \
      python3.12-dev \
      python3.12-venv \
      python3-pip \
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
      libgirepository-2.0-dev

WORKDIR /app
COPY repo/ /app/

RUN python3.12 -m pip install --break-system-packages \
      'contourpy>=1.0.1' cycler fonttools kiwisolver importlib_resources \
      packaging pillow 'pyparsing!=3.1.0' python-dateutil setuptools-scm \
      'meson-python>=0.13.1' 'pybind11>=2.13.2' \
      -r requirements/testing/all.txt && \
    python3.12 -m pip install --break-system-packages sphinx!=6.1.2

RUN python3.12 -m pip install --break-system-packages --only-binary :all: \
      pycairo 'cairocffi>=0.8' 'PyGObject' || true && \
    (python3.12 -c 'import gi; gi.require_version("Gtk", "4.0"); from gi.repository import Gtk' && \
     echo 'PyGObject 4 is available' || echo 'PyGObject 4 is not available') && \
    (python3.12 -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk' && \
     echo 'PyGObject 3 is available' || echo 'PyGObject 3 is not available')

RUN python3.12 -m pip install --break-system-packages --only-binary :all: pyqt5 && \
    python3.12 -c 'import PyQt5.QtCore' && \
    echo 'PyQt5 is available' || \
    echo 'PyQt5 is not available'

RUN python3.12 -m pip install --break-system-packages --only-binary :all: pyqt6 && \
    python3.12 -c 'import PyQt6.QtCore' && \
    echo 'PyQt6 is available' || \
    echo 'PyQt6 is not available'

RUN python3.12 -m pip install --break-system-packages --only-binary :all: pyside6 && \
    python3.12 -c 'import PySide6.QtCore' && \
    echo 'PySide6 is available' || \
    echo 'PySide6 is not available'

RUN python3.12 -m pip install --break-system-packages --only-binary :all: \
      -f "https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-24.04" \
      wxPython && \
    python3.12 -c 'import wx' && \
    echo 'wxPython is available' || \
    echo 'wxPython is not available'

RUN ccache -s && \
    git describe && \
    export CPPFLAGS='--coverage -fprofile-abs-path' && \
    python3.12 -m pip install --break-system-packages --no-deps --no-build-isolation --verbose \
      --config-settings=setup-args="-DrcParams-backend=Agg" \
      --editable .[dev]

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
