FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CC=gcc-14
ENV CXX=g++-14
ENV LD=ld
ENV CPPFLAGS=-Wall

RUN apt-get update && apt-get install -y \
  gcc-14 g++-14 \
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
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
