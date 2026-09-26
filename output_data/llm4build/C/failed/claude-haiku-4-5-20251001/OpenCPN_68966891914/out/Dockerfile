FROM ubuntu:latest

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    make \
    g++ \
    gcc \
    pkg-config \
    libwxgtk3.2-dev \
    libwxgtk3.2-1 \
    curl \
    wget \
    ca-certificates \
    sudo \
    devscripts \
    equivs \
    libgtk-3-dev \
    libglew-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libtinyxml-dev \
    libbz2-dev \
    zlib1g-dev \
    libexpat1-dev \
    libsqlite3-dev \
    libwxsvg-dev \
    libgps-dev \
    portaudio19-dev \
    libportaudio2 \
    rapidjson-dev \
    libarchive-dev \
    libudev-dev \
    libusb-1.0-0-dev \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy the run.sh script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]