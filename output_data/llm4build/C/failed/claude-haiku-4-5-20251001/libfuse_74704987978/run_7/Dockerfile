FROM ubuntu:24.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Python and system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3-pip \
    git \
    build-essential \
    cmake \
    ninja-build \
    meson \
    pkg-config \
    curl \
    wget \
    clang \
    clang-format \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Create virtual environment
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Ubuntu dependencies (full set) - do this before Python deps
# Remove sudo from the script since we're running as root in container
RUN if [ -f ./.github/workflows/install-ubuntu-dependencies.sh ]; then \
    sed 's/sudo //g' ./.github/workflows/install-ubuntu-dependencies.sh | bash -s -- --full || true; \
    fi

# Install Python dependencies from requirements.txt
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Make all shell scripts executable
RUN find /workspace -type f -name "*.sh" -exec chmod +x {} \;

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]