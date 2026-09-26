FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables for CI
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    gcc \
    g++ \
    libaom-dev \
    libdav1d-dev \
    libsvtav1enc-dev \
    libjpeg-turbo8-dev \
    libxml2 \
    libyuv-dev \
    libpng-dev \
    nasm \
    imagemagick \
    python3 \
    python3-pip \
    curl \
    pkg-config \
    meson \
    && rm -rf /var/lib/apt/lists/*

# Install Rust for rav1e
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
COPY . /workspace
RUN chown -R testuser /workspace
RUN git config --global --add safe.directory '*'
USER testuser

# Ensure run.sh is executable
RUN chmod +x /workspace/run.sh

# Entry point
CMD ["/workspace/run.sh"]