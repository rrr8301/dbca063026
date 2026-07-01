FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    curl \
    wget \
    ca-certificates \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.14-dev \
    python3.14-venv \
    python3.14-distutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.14 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

# Create working directory
WORKDIR /workspace

# Copy repository (assumes repo is in current directory)
COPY . /workspace/

# Install uv
RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install uv

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]