FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    ninja-build \
    coreutils \
    curl \
    wget \
    pkg-config \
    libssl-dev \
    ca-certificates \
    python3.14 \
    python3.14-dev \
    python3.14-venv \
    python3-pip \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.14 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository (assumes repo is available at build context)
COPY . /workspace/

# Upgrade pip and install Python dependencies
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install -r /workspace/requirements-dev.txt || true

# Install vcpkg and cmake manually
RUN mkdir -p /opt/vcpkg && \
    cd /opt/vcpkg && \
    git clone https://github.com/Microsoft/vcpkg.git . && \
    ./bootstrap-vcpkg.sh && \
    ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg

# Install CMake 3.31.8
RUN cd /tmp && \
    wget https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.tar.gz && \
    tar -xzf cmake-3.31.8-linux-x86_64.tar.gz && \
    cp -r cmake-3.31.8-linux-x86_64/* /usr/local/ && \
    rm -rf cmake-3.31.8-linux-x86_64 cmake-3.31.8-linux-x86_64.tar.gz

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]