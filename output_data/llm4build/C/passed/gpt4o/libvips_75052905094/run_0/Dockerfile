FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    gcc-14 \
    g++-14 \
    ld \
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
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install Python packages
RUN pip3 install pyvips[test] --break-system-packages

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]