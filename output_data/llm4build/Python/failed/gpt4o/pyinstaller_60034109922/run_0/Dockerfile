FROM ubuntu:24.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends \
    git \
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
    libfuse2 locales wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.11
RUN apt-get update -qq && \
    apt-get install -qq --no-install-recommends python3.11 python3.11-venv python3.11-dev && \
    ln -s /usr/bin/python3.11 /usr/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pip and Python packages
RUN python -m ensurepip && \
    python -m pip install --upgrade pip hatchling

# Set up locales
RUN locale-gen en_US.UTF-8 en_US sl_SI.UTF-8 sl_SI cs_CZ.UTF-8

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install project dependencies
RUN python -m pip install --no-index --find-links=dist pyinstaller[completion]

# Copy run.sh and set as entrypoint
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
ENTRYPOINT ["/app/run.sh"]