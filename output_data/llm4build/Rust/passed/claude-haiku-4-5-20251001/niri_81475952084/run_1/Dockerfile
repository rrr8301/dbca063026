FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone
RUN echo "UTC" > /etc/timezone && \
    ln -s /usr/share/zoneinfo/UTC /etc/localtime

# Install tzdata and base dependencies
RUN apt-get update -y && \
    apt-get install -y tzdata && \
    apt-get install -y \
    git \
    build-essential \
    pkg-config \
    curl \
    gcc \
    clang \
    libudev-dev \
    libgbm-dev \
    libxkbcommon-dev \
    libegl1-mesa-dev \
    libwayland-dev \
    libinput-dev \
    libdbus-1-dev \
    libsystemd-dev \
    libseat-dev \
    libpipewire-0.3-dev \
    libpango1.0-dev \
    libdisplay-info-dev && \
    rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Install Rust toolchain (stable) as root
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser /workspace && \
    chown -R testuser /root/.cargo /root/.rustup

# Copy and set run.sh as entrypoint (before switching user)
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set up Rust environment for testuser
ENV PATH="/root/.cargo/bin:${PATH}"

ENTRYPOINT ["/workspace/run.sh"]