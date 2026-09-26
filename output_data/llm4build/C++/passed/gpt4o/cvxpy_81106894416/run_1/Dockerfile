FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git curl wget build-essential cmake ninja-build g++ make clang cargo tzdata && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Python 3.11
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3.11 python3.11-venv python3.11-dev && \
    ln -sf /usr/bin/python3.11 /usr/bin/python && \
    ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Python packages
RUN python -m pip install --upgrade pip && \
    python -m pip install uv

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create a non-root user and switch to it
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set run.sh as entrypoint
ENTRYPOINT ["/workspace/run.sh"]