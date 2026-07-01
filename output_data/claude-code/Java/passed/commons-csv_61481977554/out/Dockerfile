FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install Java 17 (Temurin distribution)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

# Install Maven 3.8.1 from Apache
RUN mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz | \
    tar -xzf - -C /opt/maven --strip-components=1 && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn

ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy and make run script executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
