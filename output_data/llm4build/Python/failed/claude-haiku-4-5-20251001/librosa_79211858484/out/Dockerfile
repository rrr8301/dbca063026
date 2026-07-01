FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install OS dependencies
RUN apt-get update -yy && \
    apt-get install -yy \
    libsamplerate0 \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Install Miniforge
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/miniforge && \
    rm /tmp/miniforge.sh

# Initialize conda for bash shell
RUN /opt/miniforge/bin/conda init bash && \
    /opt/miniforge/bin/conda config --system --prepend channels conda-forge && \
    /opt/miniforge/bin/conda config --system --set auto_update_conda false

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace /opt/miniforge

# Copy and make run script executable (as root, before switching user)
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set PATH to include conda
ENV PATH=/opt/miniforge/bin:$PATH

# Create and activate conda environment
RUN /opt/miniforge/bin/conda create -n test python=3.13 -y && \
    /opt/miniforge/bin/conda clean -afy

SHELL ["/bin/bash", "-l", "-c"]

ENTRYPOINT ["/workspace/run.sh"]