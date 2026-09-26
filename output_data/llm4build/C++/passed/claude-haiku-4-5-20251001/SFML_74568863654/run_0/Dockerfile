FROM ubuntu:24.04

# Set timezone non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables for the build
ENV DISPLAY=":99"
ENV GALLIUM_DRIVER=llvmpipe
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    g++ \
    make \
    ccache \
    clang \
    xorg-dev \
    libharfbuzz-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    libudev-dev \
    libflac-dev \
    libvorbis-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    libmbedtls-dev \
    libssh2-1-dev \
    xvfb \
    fluxbox \
    gcovr \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]