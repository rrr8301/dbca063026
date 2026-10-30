FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libssl-dev \
    python3.11 \
    python3.11-dev \
    python3-pip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Set custom PyPI index
ENV UV_DEFAULT_INDEX="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"
ENV PIP_INDEX_URL="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install uv
RUN pip install 'uv~=0.11.2'

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]