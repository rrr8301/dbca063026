FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JDK_DISTRIBUTION=corretto
ENV CI_JDK_MAJOR_VERSION=17
ENV RUNTIME_JDK=17

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN chmod +x /app/gradlew && \
    chmod +x /app/pulsar-build/*.sh

RUN /app/gradlew --version

RUN ./gradlew assemble \
    -x :pulsar-client-shaded:shadowJar \
    -x :pulsar-client-admin-shaded:shadowJar \
    -x :pulsar-client-all:shadowJar \
    -x :microbench:shadowJar \
    rat licenseMain licenseTest checkstyleMain checkstyleTest \
    --no-configuration-cache

RUN ./gradlew -Pdocker :tests:java-test-image:dockerBuild

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
