FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.11
RUN add-apt-repository -y ppa:deadsnakes/ppa

# Install system dependencies including Python 3.11
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Ensure pip is installed and upgrade to 25.3
RUN python3.11 -m ensurepip --upgrade && \
    python3.11 -m pip install --upgrade pip==25.3

# Create work directory
WORKDIR /workspace

# Copy repository (assumes it's already checked out or will be in run.sh)
COPY . /workspace/

# Install tox
RUN pip install --upgrade pip==25.3 && \
    pip install tox

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]