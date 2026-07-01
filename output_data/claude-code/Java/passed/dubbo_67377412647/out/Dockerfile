FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

ENV FORK_COUNT=2 \
    FAIL_FAST=0 \
    SHOW_ERROR_DETAIL=1 \
    VERSIONS_LIMIT=4 \
    JACOCO_ENABLE=true \
    DISABLE_FILE_SYSTEM_TEST=true \
    ZOOKEEPER_VERSION=3.7.2 \
    CANDIDATE_VERSIONS='spring.version:5.3.24,6.1.5;spring-boot.version:2.7.6,3.2.3;' \
    MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' \
    MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast'

RUN mkdir -p /app/.tmp/zookeeper && \
    cd /app/.tmp/zookeeper && \
    wget -t 1 -T 120 -c https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -O apache-zookeeper-bin.tar.gz || \
    wget -t 1 -T 120 -c https://apache.website-solution.net/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -O apache-zookeeper-bin.tar.gz || \
    wget -t 1 -T 120 -c http://ftp.jaist.ac.jp/pub/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -O apache-zookeeper-bin.tar.gz || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
