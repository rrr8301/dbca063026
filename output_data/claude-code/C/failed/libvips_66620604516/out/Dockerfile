FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CC=clang-19
ENV CXX=clang++-19
ENV LD=ld.lld-19
ENV CPPFLAGS=-Wall

# Install system dependencies
RUN apt-get update && apt-get install -y \
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
    clang-19 \
    libclang-rt-19-dev \
    lld-19 \
    llvm-19 \
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the repository
COPY repo /app

# Prepare sanitizers environment for TSan
ENV CPPFLAGS="-g -fno-omit-frame-pointer -fno-sanitize=function -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION"
ENV LDFLAGS="-g -shared-libsan"
ENV ASAN_OPTIONS="suppressions=/app/suppressions/asan.supp:fast_unwind_on_malloc=0:allocator_may_return_null=1"
ENV LSAN_OPTIONS="suppressions=/app/suppressions/lsan.supp:fast_unwind_on_malloc=0"
ENV TSAN_OPTIONS="suppressions=/app/suppressions/tsan.supp:halt_on_error=1:print_suppressions=1:ignore_noninstrumented_modules=1:halt_on_error=0"
ENV UBSAN_OPTIONS="suppressions=/app/suppressions/ubsan.supp:halt_on_error=1:abort_on_error=1:print_stacktrace=1"
ENV GLIBCXX_FORCE_NEW=1

# Get TSan DSO
RUN TSAN_DSO=$(clang-19 -print-file-name=libclang_rt.tsan-x86_64.so) && \
    echo "TSAN_DSO=$TSAN_DSO" && \
    echo "LD_LIBRARY_PATH=$(dirname $TSAN_DSO)" >> /etc/environment && \
    export SANITIZE_DSO=$TSAN_DSO

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
