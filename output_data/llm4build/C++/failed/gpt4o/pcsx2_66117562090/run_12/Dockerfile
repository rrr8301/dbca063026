# Use an official Ubuntu as a parent image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    unzip \  # Add unzip here
    && wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc \
    && add-apt-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" \
    && apt-get update && apt-get install -y \
    build-essential \
    ccache \
    clang-17 \
    cmake \
    extra-cmake-modules \
    git \
    libasound2-dev \
    libaio-dev \
    libcurl4-openssl-dev \
    libdbus-1-dev \
    libdecor-0-dev \
    libegl-dev \
    libevdev-dev \
    libfontconfig-dev \
    libfreetype-dev \
    libfuse2 \
    libgtk-3-dev \
    libgudev-1.0-dev \
    libharfbuzz-dev \
    libinput-dev \
    libopengl-dev \
    libopus-dev \
    libpcap-dev \
    libpipewire-0.3-dev \
    libpulse-dev \
    libssl-dev \
    libudev-dev \
    libva-dev \
    libvpl2 \
    libvpl-dev \
    libwayland-dev \
    libx11-dev \
    libx11-xcb-dev \
    libx264-dev \
    libxcb1-dev \
    libxcb-composite0-dev \
    libxcb-cursor-dev \
    libxcb-damage0-dev \
    libxcb-glx0-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-present-dev \
    libxcb-randr0-dev \
    libxcb-render0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-sync-dev \
    libxcb-util-dev \
    libxcb-xfixes0-dev \
    libxcb-xinput-dev \
    libxcb-xkb-dev \
    libxext-dev \
    libxkbcommon-x11-dev \
    libxrandr-dev \
    lld-17 \
    llvm-17 \
    nasm \
    ninja-build \
    patchelf \
    pkg-config \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the necessary scripts into the container
COPY .github/workflows/scripts/linux/build-dependencies-qt.sh /app/scripts/build-dependencies-qt.sh
COPY .github/workflows/scripts/linux/appimage-qt.sh /app/scripts/appimage-qt.sh

# Copy the run script into the container
COPY run.sh /app/run.sh

# Make the scripts executable
RUN chmod +x /app/run.sh /app/scripts/build-dependencies-qt.sh /app/scripts/appimage-qt.sh

# Define the command to run the application
CMD ["/app/run.sh"]