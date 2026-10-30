FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    build-essential \
    g++ \
    make \
    curl \
    wget \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    python3.14 \
    python3.14-dev \
    python3.14-venv \
    python3-pip \
    openjdk-11-jdk \
    maven \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for Python 3.14
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install Python dependencies
RUN python -m pip install --upgrade pip setuptools wheel && \
    if [ -f requirements-dev.txt ]; then pip install -r requirements-dev.txt; fi && \
    if [ -f onnxruntime/python/tools/transformers/pytest.ini ]; then pip install pytest; fi

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]