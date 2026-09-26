FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Java 25 from Eclipse Adoptium Temurin
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
