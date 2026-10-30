FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/app/.mvn:$PATH"

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3.12 \
    python3-pip \
    openjdk-17-jdk-headless \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN chmod +x ./mvnw ./mvnw.cmd

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
