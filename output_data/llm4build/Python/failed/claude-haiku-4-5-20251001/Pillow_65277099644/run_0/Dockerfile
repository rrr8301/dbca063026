FROM ubuntu:22.04

# Set timezone noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV COVERAGE_CORE=sysmon
ENV FORCE_COLOR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONOPTIMIZE=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    git \
    curl \
    wget \
    ca-certificates \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libtiff-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    xvfb \
    sway \
    wayland-protocols \
    libwayland-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Upgrade pip and install build tools
RUN python3 -m pip install --upgrade pip setuptools wheel

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and execute run.sh
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]