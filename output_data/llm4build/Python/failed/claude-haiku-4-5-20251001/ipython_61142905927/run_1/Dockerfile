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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository (assumes repo is in current directory)
COPY . /workspace/

# Install uv and Python 3.14-dev
# Note: Python 3.14-dev needs to be installed via alternative means
# For Docker, we'll use the deadsnakes nightly PPA which has more recent builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/nightly \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.13-dev \
    python3.13-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.13 as default (closest available to 3.14-dev)
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.13 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1

# Install pip and uv
RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install uv

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]