FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    clang \
    build-essential \
    git \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install pipx and setup PATH
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install pipx && \
    python3 -m pipx ensurepath

# Install meson and ninja via pipx
RUN python3 -m pipx install meson ninja

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]