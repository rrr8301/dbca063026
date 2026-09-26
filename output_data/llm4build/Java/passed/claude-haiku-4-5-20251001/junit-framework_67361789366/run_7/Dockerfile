FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Prevent interactive prompts during package installation
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Install Temurin JDK 25 (for Gradle build)
# Using the latest available JDK 25 release
RUN mkdir -p /opt/jdk25 && \
    curl -fsSL https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B37/OpenJDK25U-jdk_x64_linux_hotspot_25_37.tar.gz \
    -o /tmp/jdk25.tar.gz && \
    tar -xzf /tmp/jdk25.tar.gz -C /opt/jdk25 --strip-components=1 && \
    rm /tmp/jdk25.tar.gz

# Install Temurin JDK 21 (for toolchain support)
RUN mkdir -p /opt/jdk21 && \
    curl -fsSL https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.3%2B9/OpenJDK21U-jdk_x64_linux_hotspot_21.0.3_9.tar.gz \
    -o /tmp/jdk21.tar.gz && \
    tar -xzf /tmp/jdk21.tar.gz -C /opt/jdk21 --strip-components=1 && \
    rm /tmp/jdk21.tar.gz

# Install Temurin JDK 17 (for toolchain support)
RUN mkdir -p /opt/jdk17 && \
    curl -fsSL https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz \
    -o /tmp/jdk17.tar.gz && \
    tar -xzf /tmp/jdk17.tar.gz -C /opt/jdk17 --strip-components=1 && \
    rm /tmp/jdk17.tar.gz

# Set default JAVA_HOME to JDK 25 (matching CI's Gradle JDK)
ENV JAVA_HOME=/opt/jdk25 \
    PATH=/opt/jdk25/bin:$PATH \
    JDK17=/opt/jdk17 \
    JDK21=/opt/jdk21 \
    JDK25=/opt/jdk25

# Create non-root user
RUN useradd -m testuser

# Transfer workspace ownership
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]