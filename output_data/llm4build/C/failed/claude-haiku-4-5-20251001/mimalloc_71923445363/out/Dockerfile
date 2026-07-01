FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone before installing tzdata
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install tzdata and other dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    git \
    cmake \
    ninja-build \
    build-essential \
    gcc \
    g++ \
    clang \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser /workspace

# Copy and make run script executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

USER testuser

ENTRYPOINT ["/workspace/run.sh"]