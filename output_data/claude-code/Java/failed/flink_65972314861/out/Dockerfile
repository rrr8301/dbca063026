FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk-headless \
    maven \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-dev \
    moreutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN chmod +x /app/mvnw && \
    chmod +x /app/tools/azure-pipelines/*.sh && \
    chmod +x /app/tools/ci/*.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
