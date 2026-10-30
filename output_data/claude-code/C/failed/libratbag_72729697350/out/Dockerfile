FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gcc g++ pkg-config systemd libevdev-dev libglib2.0-dev \
    libjson-glib-dev libsystemd-dev libudev-dev libunistring-dev \
    python3-dev python3-evdev swig python3-sphinx \
    check python3-gi python3-lxml valgrind \
    python3-pip git curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages meson ninja libevdev pyudev pytest sphinx_rtd_theme black==25.12.0 ruff==0.15.12

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
