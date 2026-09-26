FROM golang:1.23-bookworm

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    make \
    build-essential \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    python3-full \
    clang \
    llvm \
    && rm -rf /var/lib/apt/lists/*

# Install Rust 1.91 with clippy and rustfmt
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y --default-toolchain 1.91 --component clippy,rustfmt
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create Python virtual environment and install dependencies
RUN python3 -m venv /workspace/venv && \
    /workspace/venv/bin/python3 -m pip install --upgrade pip && \
    /workspace/venv/bin/python3 -m pip install pytest pytest-html pytest-xdist ruamel.yaml

# Set venv as default Python environment
ENV PATH="/workspace/venv/bin:${PATH}"

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]