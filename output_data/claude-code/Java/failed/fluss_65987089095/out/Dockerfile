FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.8.6
RUN wget -q https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
    tar -xzf apache-maven-3.8.6-bin.tar.gz -C /opt && \
    rm apache-maven-3.8.6-bin.tar.gz && \
    ln -s /opt/apache-maven-3.8.6 /opt/maven && \
    update-alternatives --install /usr/bin/mvn mvn /opt/maven/bin/mvn 100

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
