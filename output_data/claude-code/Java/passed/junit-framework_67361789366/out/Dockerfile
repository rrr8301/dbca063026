FROM eclipse-temurin:25-jdk-jammy

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    zip \
    build-essential \
    ca-certificates \
    openjdk-17-jdk-headless \
    openjdk-21-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Set up Java homes for different versions
RUN mkdir -p /opt/java && \
    ln -s /usr/lib/jvm/java-17-openjdk-amd64 /opt/java/java17 && \
    ln -s /usr/lib/jvm/java-21-openjdk-amd64 /opt/java/java21

ENV JDK17=/opt/java/java17
ENV JDK21=/opt/java/java21
ENV GRAALVM_HOME=/opt/java/java21

# For Java 24, use Java 21 as fallback
RUN ln -s /opt/java/java21 /opt/java/java24

ENV JDK24=/opt/java/java24

# Java 25 is already installed from the base image at /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk \
    JDK25=/opt/java/openjdk \
    PATH=/opt/java/openjdk/bin:$PATH

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
