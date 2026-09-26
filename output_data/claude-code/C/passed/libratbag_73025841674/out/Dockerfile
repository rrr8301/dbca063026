FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && \
    apt-get install -yq --no-install-suggests --no-install-recommends \
    gcc g++ pkg-config systemd libevdev-dev libglib2.0-dev \
    libjson-glib-dev libsystemd-dev libudev-dev libunistring-dev \
    python3-dev python3-evdev swig python3-sphinx \
    check python3-gi python3-lxml valgrind \
    git curl wget tree python3-pip

# Install pip packages (skip pip upgrade due to Debian packaging)
RUN python3 -m pip install --break-system-packages \
    meson ninja libevdev pyudev pytest sphinx_rtd_theme black==25.12.0 ruff==0.15.12

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
