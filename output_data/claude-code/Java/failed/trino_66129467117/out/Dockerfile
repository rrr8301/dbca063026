FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CONTINUOUS_INTEGRATION=true
ENV MAVEN=./mvnw
ENV MAVEN_OPTS="-Xmx512M -XX:+ExitOnOutOfMemoryError"
ENV MAVEN_INSTALL_OPTS="-Xmx3G -XX:+ExitOnOutOfMemoryError"
ENV MAVEN_FAST_INSTALL="-B -V -T 1C -DskipTests -Dmaven.source.skip=true -Dair.check.skip-all"
ENV MAVEN_COMPILE_COMMITS="-B --quiet -T 1C -DskipTests -Dmaven.source.skip=true -Dair.check.skip-all=true -Dmaven.javadoc.skip=true --no-snapshot-updates --no-transfer-progress"
ENV MAVEN_TEST="-B -Dmaven.source.skip=true -Dair.check.skip-all --fail-at-end"
ENV TESTCONTAINERS_PULL_PAUSE_TIMEOUT=600
ENV SEGMENT_DOWNLOAD_TIMEOUT_MINS=5
ENV PTL_TMP_DOWNLOAD_PATH=/tmp/pt_java_downloads

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    jq \
    openssl \
    netcat-openbsd \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Temurin JDK 25.0.2
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v24.12.0
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN chmod +x /app/mvnw

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
