FROM python:3.14-slim

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Set custom PyPI mirror
ENV UV_DEFAULT_INDEX="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"
ENV PIP_INDEX_URL="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"

# Update apt and install OS-level dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    git \
    build-essential \
    cmake \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install uv and project dependencies
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install uv~=0.5.30 && \
    uv pip install --system .[minimum-jaxlib] -r build/test-requirements.txt

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]