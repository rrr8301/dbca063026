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
    curl \
    wget \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Meson
RUN pip3 install meson

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
COPY . /workspace
RUN chown -R testuser /workspace
RUN git config --global --add safe.directory '*'
USER testuser

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]