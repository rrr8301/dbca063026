FROM python:3.8-slim

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    g++ \
    make \
    cmake \
    ninja-build \
    openjdk-17-jdk \
    maven \
    gradle \
    nodejs \
    npm \
    golang-go \
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK (for android_tests module)
RUN apt-get update && apt-get install -y --no-install-recommends \
    android-sdk \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/usr/lib/android-sdk

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Install Python dependencies (if any)
RUN python3.8 -m pip install --upgrade pip setuptools wheel

# Copy and set up run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]