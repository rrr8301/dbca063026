FROM ubuntu:22.04

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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 8 (Corretto)
RUN curl -fL https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.tar.gz -o /tmp/corretto-8.tar.gz && \
    tar -xzf /tmp/corretto-8.tar.gz -C /opt && \
    rm /tmp/corretto-8.tar.gz && \
    ln -s /opt/amazon-corretto-* /opt/java-8

ENV JAVA_HOME=/opt/java-8 \
    PATH=/opt/java-8/bin:$PATH

# Install Maven from official binary
RUN curl -fL https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -o /tmp/maven.tar.gz && \
    tar -xzf /tmp/maven.tar.gz -C /opt && \
    rm /tmp/maven.tar.gz && \
    ln -s /opt/apache-maven-* /opt/maven

ENV MAVEN_HOME=/opt/maven \
    PATH=/opt/maven/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]