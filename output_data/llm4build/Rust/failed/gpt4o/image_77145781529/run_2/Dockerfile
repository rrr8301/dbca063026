FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"

# Create non-root user
RUN useradd -m testuser

# Switch to non-root user
USER testuser

# Set up Rust environment for the non-root user
RUN /bin/bash -c "source $HOME/.cargo/env && rustup default nightly"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]