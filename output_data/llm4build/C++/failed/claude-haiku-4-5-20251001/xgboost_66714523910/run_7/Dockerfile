FROM ubuntu:22.04

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
    python3.10 \
    python3.10-dev \
    python3-pip \
    python3-setuptools \
    libgomp1 \
    libopenblas-dev \
    liblapack-dev \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

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