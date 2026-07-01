FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Free some space by removing unnecessary packages
RUN rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    gcc-13 \
    g++-13 \
    clang-19 \
    cmake \
    ninja-build \
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
    ccache \
    python3 \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Setup locales
RUN locale-gen en_US && \
    locale-gen en_US.UTF-8 && \
    locale-gen es_ES && \
    locale-gen es_ES.UTF-8 && \
    locale-gen fr_FR && \
    locale-gen fr_FR.UTF-8 && \
    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale

WORKDIR /app

COPY repo /app/

RUN ./configure.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
