FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base dependencies
RUN apt-get update && apt-get install -y \
    wget curl git ca-certificates gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add LLVM repository
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" | tee /etc/apt/sources.list.d/llvm.list

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential ccache clang-17 cmake curl extra-cmake-modules git libasound2-dev libaio-dev \
    libcurl4-openssl-dev libdbus-1-dev libdecor-0-dev libegl-dev libevdev-dev libfontconfig-dev libfreetype-dev libfuse2 libgtk-3-dev libgudev-1.0-dev \
    libharfbuzz-dev libinput-dev libopengl-dev libopus-dev libpcap-dev libpipewire-0.3-dev libpulse-dev libssl-dev libudev-dev libva-dev libvpl2 libvpl-dev \
    libwayland-dev libx11-dev libx11-xcb-dev libx264-dev libxcb1-dev libxcb-composite0-dev libxcb-cursor-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-icccm4-dev \
    libxcb-image0-dev libxcb-keysyms1-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-sync-dev libxcb-util-dev libxcb-xfixes0-dev libxcb-xinput-dev libxcb-xkb-dev libxext-dev libxkbcommon-x11-dev libxrandr-dev \
    lld-17 llvm-17 nasm ninja-build patchelf pkg-config zlib1g-dev aria2 unzip \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make all scripts in .github/workflows/scripts executable
RUN find /workspace/.github/workflows/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]