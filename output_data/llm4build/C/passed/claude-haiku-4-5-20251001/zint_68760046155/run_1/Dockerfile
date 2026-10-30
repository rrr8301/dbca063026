FROM ubuntu:22.04

# Set timezone and CI environment variables
ENV TZ=America/Los_Angeles \
    CI=true \
    GITHUB_ACTIONS=true \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    ca-certificates \
    libpng-dev \
    qt5-qmake \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5test5 \
    qtbase5-dev \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen de_DE.UTF-8 && update-locale LANG=de_DE.UTF-8

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]