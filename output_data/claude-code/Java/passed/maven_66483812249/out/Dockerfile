FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV MIMIR_VERSION=0.11.2
ENV MIMIR_BASEDIR=/root/.mimir
ENV MIMIR_LOCAL=/root/.mimir/local
ENV MAVEN_OPTS="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof"
ENV MVNW_REPOURL="https://maven-central.storage-download.googleapis.com/maven2"

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    graphviz \
    maven \
    openjdk-17-jdk \
    openjdk-21-jdk \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

# Copy Mimir configuration files
RUN mkdir -p /root/.mimir /root/.m2
COPY repo/.github/ci-mimir-session.properties /root/.mimir/session.properties
COPY repo/.github/ci-mimir-daemon.properties /root/.mimir/daemon.properties
COPY repo/.github/ci-extensions.xml /root/.m2/extensions.xml

# Copy and set execute permissions on run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
