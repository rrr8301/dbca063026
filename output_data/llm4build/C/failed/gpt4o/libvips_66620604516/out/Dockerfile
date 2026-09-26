FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    meson gi-docgen pkg-config \
    libarchive-dev libcfitsio-dev libcgif-dev \
    libexif-dev libexpat1-dev libffi-dev \
    libfftw3-dev libheif-dev libheif-plugin-aomenc \
    libheif-plugin-x265 libhwy-dev libimagequant-dev \
    libjpeg-dev libjxl-dev liblcms2-dev \
    libmatio-dev libnifti-dev libopenexr-dev \
    libopenjp2-7-dev libopenslide-dev libpango1.0-dev \
    libpng-dev libpoppler-glib-dev librsvg2-dev \
    libtiff5-dev libwebp-dev \
    clang-19 libclang-rt-19-dev lld-19 llvm-19 \
    git python3-pip

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Python packages
RUN pip3 install pyvips[test] --break-system-packages

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]