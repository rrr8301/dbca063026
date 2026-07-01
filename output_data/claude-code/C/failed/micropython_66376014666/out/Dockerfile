FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3 \
    python3-pip \
    wget \
    curl \
    pkg-config \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.11 and set as default
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && rm -rf /var/lib/apt/lists/*

# Install 32-bit support and dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    gcc-multilib \
    g++-multilib \
    libffi-dev:i386 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN python3 -m pip install --no-cache-dir pyelftools ar

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
