FROM ubuntu:22.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    sudo \
    build-essential \
    cmake \
    libssl-dev \
    m4 && \
    rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /workspace

# Copy the repository into the container
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create a non-root user and switch to it
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Entry point
CMD ["bash", "/workspace/run.sh"]