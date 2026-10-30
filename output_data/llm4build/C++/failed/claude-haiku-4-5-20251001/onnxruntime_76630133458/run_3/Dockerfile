FROM python:3.14-slim

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
    openjdk-17-jre-headless \
    maven \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for Maven
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

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