FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    curl \
    wget \
    build-essential \
    python3-pip \
    python3-venv \
    npm \
    nodejs \
    yarn \
    make \
    cmake \
    ninja-build \
    g++ \
    pkg-config \
    libssl-dev \
    libpq-dev \
    docker.io \
    ca-certificates \
    sudo \
    software-properties-common \
    bash \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install virtualenv and upgrade pip with --break-system-packages flag
RUN python3.11 -m pip install --upgrade --break-system-packages pip setuptools wheel && \
    python3.11 -m pip install --break-system-packages virtualenv

# Configure sudo for docker commands without password
RUN echo "ALL ALL=(ALL) NOPASSWD: /usr/bin/docker" >> /etc/sudoers.d/docker && \
    chmod 0440 /etc/sudoers.d/docker

# Make run.sh executable
RUN chmod +x run.sh

# Set environment variables for services
ENV REDIS_URL=redis://redis:6379
ENV MINIO_URL=http://minio:9000
ENV MINIO_ACCESS_KEY=administrator
ENV MINIO_SECRET_KEY=administrator
ENV PYTHONUNBUFFERED=1

CMD ["/bin/bash"]