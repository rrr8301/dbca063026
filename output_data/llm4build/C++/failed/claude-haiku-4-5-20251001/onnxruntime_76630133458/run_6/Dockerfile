FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies including Python 3.14 and Java 17
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    gnupg \
    && add-apt-repository --no-update --yes ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    python3.14 \
    python3.14-venv \
    python3.14-dev \
    python3-pip \
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

# Set Python 3.14 as default
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