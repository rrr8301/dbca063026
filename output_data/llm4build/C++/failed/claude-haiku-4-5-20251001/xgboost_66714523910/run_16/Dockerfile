FROM python:3.10-slim

# Set timezone non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    make \
    g++ \
    gcc \
    clang \
    python3-dev \
    libgomp1 \
    libopenblas-dev \
    liblapack-dev \
    libboost-all-dev \
    curl \
    wget \
    ca-certificates \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python -m pip install --upgrade pip setuptools wheel

# Install Python testing and build dependencies
RUN pip install pytest pytest-cov numpy scipy scikit-learn pandas matplotlib \
    auditwheel pydistcheck awscli

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Create wheelhouse directory for wheel artifacts
RUN mkdir -p /workspace/wheelhouse

# Copy run.sh script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set default command (can be overridden)
CMD ["/bin/bash"]