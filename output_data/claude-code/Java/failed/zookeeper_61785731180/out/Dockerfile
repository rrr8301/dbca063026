FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    maven \
    libcppunit-dev \
    libsasl2-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENV MAVEN_OPTS=-Djansi.force=true
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

ENTRYPOINT ["/run.sh"]
