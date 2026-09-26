FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    openjdk-25-jdk \
    openjdk-21-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

COPY toolchains.xml /root/.m2/toolchains.xml

WORKDIR /app
COPY repo/ /app/

RUN mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
