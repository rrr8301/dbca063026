FROM ubuntu:24.04

# Set timezone noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 21 (Temurin) via official binary
RUN mkdir -p /opt/java && \
    cd /opt/java && \
    curl -fsSL https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.1%2B12/OpenJDK21U-jdk_x64_linux_hotspot_21.0.1_12.tar.gz -o jdk.tar.gz && \
    tar -xzf jdk.tar.gz && \
    rm jdk.tar.gz && \
    mv jdk-21.0.1+12 /opt/java/jdk21

ENV JAVA_HOME=/opt/java/jdk21
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Maven via official binary
RUN mkdir -p /opt/maven && \
    cd /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -o maven.tar.gz && \
    tar -xzf maven.tar.gz && \
    rm maven.tar.gz && \
    mv apache-maven-3.9.5 /opt/maven/maven

ENV MAVEN_HOME=/opt/maven/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]