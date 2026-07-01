FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install essential build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    git \
    curl \
    wget \
    ca-certificates \
    pkg-config \
    libicu-dev \
    locales \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create a non-root user for building and testing
RUN useradd -m -s /bin/bash postgres && \
    usermod -aG sudo postgres && \
    echo "postgres ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Create work directory
WORKDIR /workspace
RUN chown -R postgres:postgres /workspace

# Copy the AGE repository
COPY . /workspace/age
RUN chown -R postgres:postgres /workspace/age

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh && \
    chown postgres:postgres /workspace/run.sh

# Switch to non-root user
USER postgres

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]