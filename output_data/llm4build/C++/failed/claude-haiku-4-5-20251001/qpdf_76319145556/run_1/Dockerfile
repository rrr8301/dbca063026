FROM ubuntu:24.04

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
ENV QTEST_COLOR=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    wget \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    clang-format \
    flake8 \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git safe directory (avoid ownership errors)
RUN git config --global --add safe.directory '*'

# Install Python dependencies from requirements.txt if present
RUN if [ -f qpdf/manual/requirements.txt ]; then \
    pip3 install --no-cache-dir -r qpdf/manual/requirements.txt; \
    fi

# Create non-root user
RUN useradd -m testuser && chown -R testuser:testuser /workspace

# Make run.sh executable
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Entrypoint
ENTRYPOINT ["/workspace/run.sh"]