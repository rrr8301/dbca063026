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
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Set up a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace

# Copy the repository into the container
COPY . /workspace

# Ensure the script is executable
RUN chmod +x /workspace/run.sh

# Configure git
RUN git config --global --add safe.directory '*'

# Switch to non-root user
USER testuser

# Install Python dependencies if any (placeholder)
# Uncomment and modify the following line if you have a requirements.txt
# RUN pip install -r requirements.txt

# Entry point
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]