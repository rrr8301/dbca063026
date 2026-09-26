FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common wget gnupg unzip && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" | tee /etc/apt/sources.list.d/llvm.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential ccache clang-17 cmake curl extra-cmake-modules git \
    libasound2-dev libaio-dev libcurl4-openssl-dev libdbus-1-dev libdecor-0-dev \
    libegl-dev libevdev-dev libfontconfig-dev libfreetype-dev libfuse2 libgtk-3-dev \
    libgudev-1.0-dev libharfbuzz-dev libinput-dev libopengl-dev libopus-dev libpcap-dev \
    libpipewire-0.3-dev libpulse-dev libssl-dev libudev-dev libva-dev libvpl2 libvpl-dev \
    libwayland-dev libx11-dev libx11-xcb-dev libx264-dev libxcb1-dev libxcb-composite0-dev \
    libxcb-cursor-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-icccm4-dev libxcb-image0-dev \
    libxcb-keysyms1-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-shm0-dev libxcb-sync-dev libxcb-util-dev \
    libxcb-xfixes0-dev libxcb-xinput-dev libxcb-xkb-dev libxext-dev libxkbcommon-x11-dev \
    libxrandr-dev lld-17 llvm-17 nasm ninja-build patchelf pkg-config zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Ensure scripts have executable permissions
RUN chmod +x .github/workflows/scripts/linux/build-dependencies-qt.sh

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]