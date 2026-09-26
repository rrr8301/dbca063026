FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    ca-certificates \
    gnupg2 \
    lsb-release \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Temurin JDK 25 (early access)
RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list > /dev/null \
    && apt-get update \
    && apt-get install -y temurin-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 for toolchain
RUN apt-get update && apt-get install -y temurin-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN mkdir -p /root/.gradle && \
    echo 'systemProp.user.name=spring-builds+github' >> /root/.gradle/gradle.properties && \
    echo 'systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false' >> /root/.gradle/gradle.properties && \
    echo 'org.gradle.daemon=false' >> /root/.gradle/gradle.properties && \
    echo 'toolchainVersion=25' >> /root/.gradle/gradle.properties && \
    echo 'systemProp.org.gradle.java.installations.auto-detect=false' >> /root/.gradle/gradle.properties && \
    echo 'systemProp.org.gradle.java.installations.auto-download=false' >> /root/.gradle/gradle.properties && \
    echo 'systemProp.org.gradle.java.installations.paths=/usr/lib/jvm/temurin-25-jdk-amd64' >> /root/.gradle/gradle.properties

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
