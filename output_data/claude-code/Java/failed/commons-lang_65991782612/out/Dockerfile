FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Java 25
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository -y ppa:openjdk-r/ppa \
    && apt-get update && apt-get install -y \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.0 (latest stable)
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz | \
    tar -xzf - -C /opt && \
    ln -s /opt/apache-maven-3.9.0 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn

ENV MAVEN_HOME=/opt/maven \
    PATH=$MAVEN_HOME/bin:$PATH

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
