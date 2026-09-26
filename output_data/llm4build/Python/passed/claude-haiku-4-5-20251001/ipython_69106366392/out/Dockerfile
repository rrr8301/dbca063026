FROM python:3.13-slim

# Set timezone to Pacific Time (noninteractive)
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
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install uv package manager
RUN pip install --no-cache-dir uv

# Install Python dependencies
RUN uv pip install --system --prerelease=allow setuptools wheel build && \
    uv pip install --system --prerelease=allow \
    --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple \
    -e .[test] && \
    uv pip install --system --prerelease=allow \
    --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple \
    check-manifest pytest-cov

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]