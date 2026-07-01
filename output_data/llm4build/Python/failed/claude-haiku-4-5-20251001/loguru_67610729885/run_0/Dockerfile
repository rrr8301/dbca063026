FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3-dev \
    python3.10 \
    python3.10-dev \
    python3-pip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Ensure pip is up-to-date and install tox
RUN python3.10 -m pip install --upgrade pip && \
    python3.10 -m pip install tox

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user and transfer ownership
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]