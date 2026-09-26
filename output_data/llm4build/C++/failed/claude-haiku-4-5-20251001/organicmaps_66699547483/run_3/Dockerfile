FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update package lists
RUN apt-get update -y

# Install build tools and dependencies
RUN apt-get install -y \
    gcc-13 \
    g++-13 \
    cmake \
    ninja-build \
    ccache \
    git \
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
    sudo

# Set up compiler alternatives
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100

# Generate required locales
RUN locale-gen en_US && \
    locale-gen en_US.UTF-8 && \
    locale-gen es_ES && \
    locale-gen es_ES.UTF-8 && \
    locale-gen fr_FR && \
    locale-gen fr_FR.UTF-8 && \
    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make configure.sh executable
RUN chmod +x /workspace/configure.sh

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]