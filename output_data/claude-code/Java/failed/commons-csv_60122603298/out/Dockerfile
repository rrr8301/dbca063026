FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.6
RUN wget -q https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar -xzf /tmp/maven.tar.gz -C /opt && \
    rm /tmp/maven.tar.gz && \
    ln -s /opt/apache-maven-3.9.6 /opt/maven

ENV M2_HOME=/opt/maven
ENV PATH=$M2_HOME/bin:$PATH

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
