FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV NODE_OPTIONS=--max-old-space-size=4096

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    git \
    build-essential \
    cmake \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.11
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pipenv
RUN pip install --no-cache-dir "pipenv<2025.0.0"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]