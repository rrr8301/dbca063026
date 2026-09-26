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
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    openjdk-17-jdk \
    zlib1g-dev \
    libffi-dev \
    libbz2-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    zip \
    unzip \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Build Python 3.14 from source
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.14.0/Python-3.14.0.tgz && \
    tar -xzf Python-3.14.0.tgz && \
    cd Python-3.14.0 && \
    ./configure --prefix=/usr/local --enable-optimizations --with-openssl=/usr && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && \
    rm -rf Python-3.14.0 Python-3.14.0.tgz

# Set Python 3.14 as default
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.14 1

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

# Install vcpkg
RUN mkdir -p /opt/vcpkg && \
    cd /opt/vcpkg && \
    git clone https://github.com/Microsoft/vcpkg.git . && \
    ./bootstrap-vcpkg.sh && \
    ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg

# Install CMake 3.31.8
RUN cd /tmp && \
    wget https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.tar.gz && \
    tar -xzf cmake-3.31.8-linux-x86_64.tar.gz && \
    rm -f /usr/local/man && \
    cp -r cmake-3.31.8-linux-x86_64/bin/* /usr/local/bin/ && \
    cp -r cmake-3.31.8-linux-x86_64/share/* /usr/local/share/ && \
    rm -rf cmake-3.31.8-linux-x86_64 cmake-3.31.8-linux-x86_64.tar.gz

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]