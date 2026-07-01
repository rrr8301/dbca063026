FROM ubuntu:22.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    sudo \
    curl \
    wget \
    build-essential \
    libssl-dev \  # Add OpenSSL development package
    && rm -rf /var/lib/apt/lists/*

# Set up a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository into the container
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Python dependencies if any (placeholder)
# RUN pip install -r requirements.txt

# Entry point
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]