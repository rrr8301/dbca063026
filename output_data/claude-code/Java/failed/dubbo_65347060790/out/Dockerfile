FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISABLE_FILE_SYSTEM_TEST=true
ENV ZOOKEEPER_VERSION=3.7.2
ENV MAVEN_OPTS="--sun-misc-unsafe-memory-access=allow"
ENV MAVEN_ARGS="-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    tar \
    gzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up Java 25 (Zulu)
RUN apt-get update && apt-get install -y \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Pre-download Zookeeper binary
RUN mkdir -p /tmp/zookeeper && \
    wget -t 1 -T 120 -c https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -O /tmp/zookeeper/apache-zookeeper-bin.tar.gz || \
    wget -t 1 -T 120 -c https://apache.website-solution.net/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -O /tmp/zookeeper/apache-zookeeper-bin.tar.gz || \
    echo "Zookeeper download may have failed, but continuing..."

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
