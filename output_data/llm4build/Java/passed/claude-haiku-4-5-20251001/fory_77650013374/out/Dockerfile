FROM ubuntu:24.04

# Set timezone and CI environment variables
ENV TZ=America/Los_Angeles \
    CI=true \
    GITHUB_ACTIONS=true \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (Temurin)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Install Python 3.8
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.8 \
    python3.8-venv \
    python3.8-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Maven (official binary)
RUN mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz | \
    tar -xz -C /opt/maven --strip-components=1 && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn

# Install Go
RUN curl -fsSL https://go.dev/dl/go1.21.0.linux-amd64.tar.gz | \
    tar -xz -C /usr/local && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go

ENV PATH=$PATH:/usr/local/go/bin

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env

ENV PATH=$PATH:$HOME/.cargo/bin

# Install Node.js (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Android SDK
RUN mkdir -p /opt/android-sdk && \
    cd /opt/android-sdk && \
    curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -o cmdline-tools.zip && \
    unzip -q cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true

ENV ANDROID_HOME=/opt/android-sdk \
    PATH=$PATH:/opt/android-sdk/cmdline-tools/latest/bin

RUN yes | sdkmanager --sdk_root=$ANDROID_HOME "platforms;android-33" "build-tools;30.0.3" 2>/dev/null || true

# Install Bazel
RUN curl -fsSL https://github.com/bazelbuild/bazel/releases/download/7.0.0/bazel-7.0.0-linux-x86_64 -o /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]