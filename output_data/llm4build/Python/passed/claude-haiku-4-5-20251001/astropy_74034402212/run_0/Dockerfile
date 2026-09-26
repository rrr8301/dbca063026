FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3-dev \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    autoconf \
    automake \
    libtool \
    make \
    gcc \
    g++ \
    gfortran \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Upgrade pip and install tox and uv
RUN python -m pip install --upgrade pip && \
    pip install tox uv

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]