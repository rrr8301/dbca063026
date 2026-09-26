FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install GraalVM 21 (using a stable release that exists)
RUN mkdir -p /opt/graalvm && \
    curl -fsSL https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-21.0.0/graalvm-community-jdk-21.0.0_linux-x64_bin.tar.gz | \
    tar -xz -C /opt/graalvm --strip-components=1 && \
    ln -s /opt/graalvm/bin/java /usr/local/bin/java-graalvm-21

# Install Temurin JDK 17
RUN mkdir -p /opt/jdk17 && \
    curl -fsSL https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.11%2B9/OpenJDK17U-jdk_x64_linux_hotspot_17.0.11_9.tar.gz | \
    tar -xz -C /opt/jdk17 --strip-components=1

# Install Temurin JDK 25 (fetch latest available release dynamically)
RUN mkdir -p /opt/jdk25 && \
    DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/adoptium/temurin25-binaries/releases/latest | \
    jq -r '.assets[] | select(.name | contains("x64_linux_hotspot") and endswith(".tar.gz")) | .browser_download_url' | head -1) && \
    if [ -z "$DOWNLOAD_URL" ]; then \
      echo "Failed to find JDK 25 release, trying alternative method..."; \
      DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/adoptium/temurin25-binaries/releases | \
      jq -r '.[0].assets[] | select(.name | contains("x64_linux_hotspot") and endswith(".tar.gz")) | .browser_download_url' | head -1); \
    fi && \
    if [ -z "$DOWNLOAD_URL" ]; then \
      echo "Failed to find JDK 25 release"; exit 1; \
    fi && \
    echo "Downloading JDK 25 from: $DOWNLOAD_URL" && \
    curl -fsSL "$DOWNLOAD_URL" | \
    tar -xz -C /opt/jdk25 --strip-components=1 && \
    /opt/jdk25/bin/java -version

# Set default JAVA_HOME to GraalVM 21
ENV JAVA_HOME=/opt/graalvm
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository (assumes build context is the repo root)
COPY . .

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]