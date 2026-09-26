FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    maven \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN mvn dependency:resolve

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
