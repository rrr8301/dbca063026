FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update package lists
RUN apt-get update -y

# Install build tools and dependencies
RUN apt-get install -y \
    build-essential \
    cmake \
    git \
    gcc-13 \
    g++-13 \
    ninja-build \
    ccache \
    clang-19 \
    libgl1-mesa-dev \
    libglvnd-dev \
    libharfbuzz-dev \
    libqt6svg6-dev \
    libxcursor-dev \
    libxi-dev \
    libxinerama-dev \
    libxrandr-dev \
    qt6-base-dev \
    qt6-positioning-dev \
    locales \
    curl \
    wget

# Create work directory
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]