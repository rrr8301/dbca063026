FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    git \
    ca-certificates \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN mkdir -p /root/.m2

# Pre-download Maven to avoid SHA-256 validation in the container
RUN MAVEN_WRAPPER_REPO=$(grep "distributionUrl" .mvn/wrapper/maven-wrapper.properties | cut -d'=' -f2) && \
    MAVEN_HOME=/opt/maven && \
    mkdir -p $MAVEN_HOME && \
    cd /tmp && \
    wget -q $MAVEN_WRAPPER_REPO -O maven.zip && \
    unzip -q maven.zip && \
    rm maven.zip && \
    mv apache-maven-3.9.14 $MAVEN_HOME/3.9.14 && \
    ln -s $MAVEN_HOME/3.9.14 $MAVEN_HOME/latest && \
    chmod +x $MAVEN_HOME/3.9.14/bin/mvn

ENV MAVEN_HOME=/opt/maven/latest
ENV PATH=$MAVEN_HOME/bin:$PATH

RUN chmod +x ./mvnw

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
