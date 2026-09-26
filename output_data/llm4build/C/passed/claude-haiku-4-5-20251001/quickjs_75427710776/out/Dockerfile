FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    pkg-config \
    libssl-dev \
    curl \
    wget \
    pipx \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install meson and ninja via pipx
RUN pipx install meson ninja && \
    pipx ensurepath

# Ensure pipx binaries are in PATH
ENV PATH="/root/.local/bin:$PATH"

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]