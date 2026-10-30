FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    openjdk-21-jdk-headless \
    || (apt-get install -y gnupg2 && \
        wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
        echo "deb https://adoptopenjdk.jfrog.io/adoptopenjdk/deb jammy main" > /etc/apt/sources.list.d/adoptopenjdk.list && \
        apt-get update && apt-get install -y adoptopenjdk-21-jdk-hotspot) && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
