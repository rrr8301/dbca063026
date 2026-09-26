# Dockerfile
FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    gcc \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN python3 -m pip install --upgrade pip && \
    pip3 install r2pipe wheel

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Ensure install.sh and build.sh are executable
RUN chmod +x sys/install.sh sys/build.sh

# Create a non-root user
RUN useradd -ms /bin/bash radareuser

# Configure Git to allow the current directory
RUN git config --global --add safe.directory /app

# Switch to non-root user to build Radare2
USER radareuser

# Build Radare2 as non-root user
RUN export CFLAGS="-O2 -Wno-unused-result" && \
    sys/install.sh || true

# Switch back to root to copy run.sh
USER root

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]