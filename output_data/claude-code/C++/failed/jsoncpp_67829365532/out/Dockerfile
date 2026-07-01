FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-pip \
    git \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install meson and ninja with specific versions
RUN pip3 install meson==1.5.1 ninja==1.11.1.1

WORKDIR /app

# Copy repository
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
