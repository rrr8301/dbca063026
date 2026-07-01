FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install APT dependencies
RUN apt-get update && apt-get install -y \
    gcc g++ pkg-config systemd libevdev-dev libglib2.0-dev \
    libjson-glib-dev libsystemd-dev libudev-dev libunistring-dev \
    python3-dev python3-evdev swig python3-sphinx check python3-gi \
    python3-lxml valgrind git curl wget

# Install PIP packages
RUN apt-get install -y python3-pip && \
    pip3 install meson ninja libevdev pyudev pytest sphinx_rtd_theme black==25.12.0 ruff==0.15.12

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]