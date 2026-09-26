FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 21 (toolchain) and JDK 17 (Maven runtime)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.14
RUN mkdir -p /opt && \
    cd /opt && \
    wget -q https://archive.apache.org/dist/maven/maven-3/3.9.14/binaries/apache-maven-3.9.14-bin.tar.gz && \
    tar -xzf apache-maven-3.9.14-bin.tar.gz && \
    rm apache-maven-3.9.14-bin.tar.gz && \
    ln -s /opt/apache-maven-3.9.14 /opt/maven

ENV PATH="/opt/maven/bin:${PATH}" \
    M2_HOME="/opt/maven"

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
