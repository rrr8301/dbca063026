FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and add Eclipse Adoptium repo for Java 25
RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    software-properties-common \
    git \
    wget \
    ca-certificates \
    build-essential \
    && wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - \
    && add-apt-repository "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" \
    && apt-get update \
    && apt-get install -y temurin-25-jdk maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/temurin-25-jdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
