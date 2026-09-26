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

# Initialize git submodules (required for dmlc-core and other dependencies)
RUN cd /workspace && \
    git init && \
    git config user.email "builder@example.com" && \
    git config user.name "Builder" && \
    git add . && \
    git commit -m "Initial commit" && \
    git submodule update --init --recursive

# Build libxgboost with CMake first
RUN mkdir -p /workspace/build && \
    cd /workspace/build && \
    cmake .. && \
    make -j$(nproc)

# Install XGBoost Python package (now that libxgboost is built)
RUN cd /workspace && \
    python -m pip install -e python-package/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]