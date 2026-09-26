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

# Install Temurin JDK 25 (using a valid stable release)
RUN mkdir -p /opt/jdk25 && \
    curl -fsSL https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B37/OpenJDK25U-jdk_x64_linux_hotspot_25_37.tar.gz | \
    tar -xz -C /opt/jdk25 --strip-components=1

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