FROM ubuntu:24.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -yy && apt-get install -yy --no-install-recommends \
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
    git \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN python3.12 -m ensurepip && \
    python3.12 -m pip install --upgrade pip setuptools wheel

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

ENTRYPOINT ["/app/run.sh"]