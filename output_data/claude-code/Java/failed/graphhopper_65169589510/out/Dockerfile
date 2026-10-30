FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Java 25 Temurin from Adoptium
RUN mkdir -p /opt/java && \
    cd /tmp && \
    wget -q https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse -O jdk.tar.gz && \
    tar -xzf jdk.tar.gz -C /opt/java && \
    rm jdk.tar.gz && \
    ls /opt/java && \
    mv /opt/java/jdk-* /opt/java/jdk25 || true && \
    ls -la /opt/java/

ENV JAVA_HOME=/opt/java/jdk25
ENV PATH=${JAVA_HOME}/bin:$PATH

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
