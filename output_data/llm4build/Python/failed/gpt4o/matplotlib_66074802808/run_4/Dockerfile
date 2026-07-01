FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update -yy && \
    apt-get install -yy --no-install-recommends \
    software-properties-common \
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
    libgirepository-2.0-dev \
    git \
    cmake \
    ninja-build \
    g++ \
    clang \
    curl \
    wget \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3.12 -m venv /opt/venv

# Activate the virtual environment and install pip
ENV PATH="/opt/venv/bin:$PATH"
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Python dependencies in the virtual environment
RUN pip install --upgrade pip setuptools wheel && \
    pip install --upgrade \
    'contourpy>=1.0.1' cycler fonttools kiwisolver importlib_resources \
    packaging pillow 'pyparsing!=3.1.0' python-dateutil setuptools-scm \
    'meson-python>=0.13.1' 'pybind11>=2.13.2' \
    -r requirements/testing/all.txt

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]