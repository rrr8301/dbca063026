FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    g++-9 \
    curl \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Setup mold linker (alternative: skip if it causes issues)
RUN wget -q https://github.com/rui314/mold/releases/download/v2.5.0/mold-2.5.0-x86_64-linux.tar.gz && \
    tar xzf mold-2.5.0-x86_64-linux.tar.gz && \
    cp mold-2.5.0-x86_64-linux/bin/mold /usr/bin/mold && \
    rm -rf mold-2.5.0-x86_64-linux* || true

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy and setup the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
