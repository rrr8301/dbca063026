FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TYPE=Debug

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3 \
    python3-venv \
    libeigen3-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Copy and set up the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
