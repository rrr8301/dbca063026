FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    unzip \
    zip \
    bash \
    shellcheck \
    openjdk-17-jdk \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Try to download and install JDK 25 from Adoptium releases
RUN mkdir -p /opt/jdk && \
    (wget -q https://api.github.com/repos/adoptium/temurin25-binaries/releases/latest -O /tmp/releases.json 2>/dev/null && \
    JDK25_URL=$(grep -o 'https://github.com/adoptium/temurin25-binaries/releases/download/[^"]*linux_hotspot[^"]*x64_bin.tar.gz' /tmp/releases.json | head -1) && \
    if [ -n "$JDK25_URL" ]; then wget -q "$JDK25_URL" -O /tmp/jdk25.tar.gz && tar -xzf /tmp/jdk25.tar.gz -C /opt/jdk && rm /tmp/jdk25.tar.gz; fi) || echo "JDK 25 not available"

# Try to download and install JDK 27 EA from jdk.java.net
RUN mkdir -p /opt/jdk27 && \
    (wget -q https://download.java.net/java/early_access/jdk27/1/GPL/openjdk-27-ea+1_linux-x64_bin.tar.gz -O /tmp/jdk27.tar.gz 2>/dev/null && \
    tar -xzf /tmp/jdk27.tar.gz -C /opt/jdk27 && rm /tmp/jdk27.tar.gz) || echo "JDK 27 EA not available"

# Set up Java homes - JAVA_HOME must be 21 or higher for NullAway build
ENV JAVA_17_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV JAVA_21_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV JAVA_25_HOME=/opt/jdk/jdk-25.0.1+9
ENV JAVA_27_HOME=/opt/jdk27/jdk-27
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=/usr/lib/jvm/java-21-openjdk-amd64/bin:$PATH

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
