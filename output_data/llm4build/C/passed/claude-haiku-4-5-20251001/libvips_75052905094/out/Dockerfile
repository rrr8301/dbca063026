FROM ubuntu:24.04

# Set timezone and disable interactive prompts
ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-14 \
    g++-14 \
    git \
    meson \
    gi-docgen \
    pkg-config \
    libarchive-dev \
    libcfitsio-dev \
    libcgif-dev \
    libexif-dev \
    libexpat1-dev \
    libffi-dev \
    libfftw3-dev \
    libheif-dev \
    libheif-plugin-aomenc \
    libheif-plugin-x265 \
    libhwy-dev \
    libimagequant-dev \
    libjpeg-dev \
    libjxl-dev \
    liblcms2-dev \
    libmatio-dev \
    libnifti-dev \
    libopenexr-dev \
    libopenjp2-7-dev \
    libopenslide-dev \
    libpango1.0-dev \
    libpng-dev \
    libpoppler-glib-dev \
    librsvg2-dev \
    libtiff5-dev \
    libwebp-dev \
    python3 \
    python3-pip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set compiler environment variables
ENV CC=gcc-14
ENV CXX=g++-14
ENV LD=ld
ENV CPPFLAGS=-Wall

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]