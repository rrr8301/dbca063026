FROM ubuntu:20.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    autoconf \
    automake \
    libtool \
    make \
    g++ \
    g++-10-arm-linux-gnueabi \
    qemu-user \
    xz-utils \
    abigail-tools \
    libunwind-dev \
    gcc-arm-linux-gnueabi && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Ensure scripts are executable
RUN chmod +x /workspace/run.sh /workspace/scripts/qemu-test-driver

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Entry point
CMD ["/workspace/run.sh"]