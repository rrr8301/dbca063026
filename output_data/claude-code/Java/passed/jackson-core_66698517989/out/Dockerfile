FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

RUN apt-get update && apt-get install -y \
    openjdk-25-jdk \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
