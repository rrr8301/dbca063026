FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set CI environment
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV QTEST_COLOR=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    build-essential \
    g++ \
    clang \
    clang-format \
    make \
    libssl-dev \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git for safe directory (avoid ownership errors)
RUN git config --global --add safe.directory '*'

# Install Python dependencies
RUN pip3 install --no-cache-dir -r manual/requirements.txt || true

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]