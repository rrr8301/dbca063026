FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    openjdk-21-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
    tar -xzf apache-maven-3.9.6-bin.tar.gz -C /opt && \
    rm apache-maven-3.9.6-bin.tar.gz

ENV PATH="/opt/apache-maven-3.9.6/bin:${PATH}"
ENV M2_HOME="/opt/apache-maven-3.9.6"

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
