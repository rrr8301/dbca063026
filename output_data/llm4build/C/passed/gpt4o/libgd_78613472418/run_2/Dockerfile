FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ca-certificates \
    cmake clang lld gcc build-essential curl libjpeg-turbo8-dev libimagequant-dev \
    libde265-dev libpng-dev libwebp-dev libtiff5-dev libx265-dev libheif-dev \
    libheif-plugin-aomenc libheif-plugin-x265 libheif-plugin-aomdec libfreetype-dev \
    libavif-dev libavifile-0.7-dev libxpm-dev libraqm-dev libexiv2-dev dh-autoreconf \
    ninja-build nasm meson git sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]