FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install tzdata and base packages
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
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m testuser

# Install Rust toolchain as non-root user
USER testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Set Rust in PATH for the user
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY --chown=testuser:testuser . /workspace/

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Copy run script
COPY --chown=testuser:testuser run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]