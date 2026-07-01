FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Java 17, Maven, and other required tools
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set Java version
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create working directory
WORKDIR /root/flink

# Copy repository
COPY repo/ /root/flink/

# Create artifact directory
RUN mkdir -p /root/artifact-directory /root/.docker-cache

# Set Maven repository directory
ENV MAVEN_REPO_FOLDER=/root/.m2/repository
ENV MAVEN_ARGS=-Dmaven.repo.local=/root/.m2/repository

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
