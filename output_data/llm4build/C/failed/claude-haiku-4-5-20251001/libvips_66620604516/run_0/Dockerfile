FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    cmake \
    ninja-build \
    pkg-config \
    meson \
    gi-docgen \
    python3 \
    python3-pip \
    clang-19 \
    libclang-rt-19-dev \
    lld-19 \
    llvm-19 \
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
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for compilation
ENV CC=clang-19
ENV CXX=clang++-19
ENV LD=ld.lld-19
ENV CPPFLAGS=-Wall

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]