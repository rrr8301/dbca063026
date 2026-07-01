FROM ubuntu:22.04

# Set non-interactive mode and timezone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -s /usr/share/zoneinfo/UTC /etc/localtime

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    ninja-build \
    python3-dev \
    python3-pip \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git for safe directory
RUN git config --global --add safe.directory '*'

# Install uv
RUN pip3 install --no-cache-dir uv

# Set Python environment variables
ENV PYTHON_VERSION="3.11"
ENV PYTHON_SUBVERSION="11"
ENV RUNNER_OS="ubuntu-22.04"
ENV SINGLE_ACTION_CONFIG="False"
ENV USE_OPENMP="False"

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Copy and prepare run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]