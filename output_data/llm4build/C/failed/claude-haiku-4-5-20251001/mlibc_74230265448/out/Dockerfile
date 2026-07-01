FROM debian:trixie

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install prerequisites
RUN apt-get update && apt-get install -y \
    meson \
    ninja-build \
    qemu-user \
    python3-setuptools \
    python3-jsonschema \
    python3-pexpect \
    python3-pip \
    netbase \
    clang \
    lld \
    git \
    rsync \
    wget \
    patchelf \
    libelf-dev \
    pkg-config \
    gcc \
    g++ \
    make \
    elfutils \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --break-system-packages -U xbstrap pyexpect

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]