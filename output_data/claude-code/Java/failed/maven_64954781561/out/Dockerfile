FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    openjdk-17-jdk \
    maven \
    git \
    curl \
    wget \
    graphviz \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /app

COPY repo/ /app/

ENV MIMIR_VERSION=0.11.3
ENV MIMIR_BASEDIR=~/.mimir
ENV MIMIR_LOCAL=~/.mimir/local
ENV MAVEN_OPTS=-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof
ENV MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2

RUN mkdir -p ~/.mimir && \
    cp .github/ci-mimir-session.properties ~/.mimir/session.properties && \
    cp .github/ci-mimir-daemon.properties ~/.mimir/daemon.properties && \
    mkdir -p ~/.m2 && \
    cp .github/ci-extensions.xml ~/.m2/extensions.xml

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
