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

# Ensure install.sh is executable
RUN chmod +x sys/install.sh

# Create a non-root user and switch to it
RUN useradd -ms /bin/bash radareuser
USER radareuser

# Configure Git to allow the current directory
RUN git config --global --add safe.directory /app

# Build Radare2
RUN export CFLAGS="-O2 -Wno-unused-result" && \
    sys/install.sh

# Switch back to root to copy run.sh and set entrypoint
USER root

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]