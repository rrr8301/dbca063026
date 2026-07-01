FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libpng-dev \
    locales \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install locale
RUN locale-gen de_DE.UTF-8 && update-locale

# Install Qt6
RUN apt-get update && apt-get install -y \
    qt6-base-dev \
    qt6-tools-dev \
    qt6-qpa-plugins \
    && rm -rf /var/lib/apt/lists/*

# Install GS1 Syntax Engine
RUN cd /tmp && \
    git clone --depth=1 https://github.com/gs1/gs1-syntax-engine && \
    cd gs1-syntax-engine/src/c-lib && \
    make lib && \
    make install && \
    cd /tmp && rm -rf gs1-syntax-engine

# Set up workspace
WORKDIR /app
COPY repo/ /app/

# Create build directory
RUN cmake -E make_directory build

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
