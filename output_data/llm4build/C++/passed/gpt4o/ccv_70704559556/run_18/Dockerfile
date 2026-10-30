FROM ubuntu:20.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    libjpeg-dev \
    libpng-dev \
    git \
    make \
    gcc \
    g++ \
    curl \
    wget \
    autoconf \
    automake \
    libtool \
    doxygen \
    pkg-config \
    libatlas-base-dev \
    libblas-dev \
    liblapack-dev \
    libgsl-dev \
    fftw3-dev \
    libtesseract-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]