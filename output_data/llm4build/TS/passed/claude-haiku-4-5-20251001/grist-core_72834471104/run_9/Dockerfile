FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
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
    docker.io \
    ca-certificates \
    sudo \
    software-properties-common \
    bash \
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

# Install virtualenv first
RUN pip install virtualenv

# Configure sudo for docker commands without password
RUN echo "ALL ALL=(ALL) NOPASSWD: /usr/bin/docker" >> /etc/sudoers.d/docker && \
    chmod 0440 /etc/sudoers.d/docker

# Set environment variables for services
ENV REDIS_URL=redis://redis:6379
ENV MINIO_URL=http://minio:9000
ENV MINIO_ACCESS_KEY=administrator
ENV MINIO_SECRET_KEY=administrator
ENV PYTHONUNBUFFERED=1

CMD ["/bin/bash"]