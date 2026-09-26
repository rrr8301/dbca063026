FROM ubuntu:24.04

# Install Java (multiple versions) and Maven
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    maven \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 25
RUN mkdir -p /usr/lib/jvm && \
    cd /tmp && \
    wget -q https://download.java.net/java/GA/jdk25/d07682892d953144b9555601a11d61d2/37/GPL/openjdk-25_linux-x64_bin.tar.gz && \
    tar -xzf openjdk-25_linux-x64_bin.tar.gz -C /usr/lib/jvm && \
    rm openjdk-25_linux-x64_bin.tar.gz && \
    mv /usr/lib/jvm/jdk-25 /usr/lib/jvm/java-25-openjdk-amd64

# Install JDK 27
RUN cd /tmp && \
    wget -q https://download.java.net/java/early_access/jdk27/37/GPL/openjdk-27-ea+37_linux-x64_bin.tar.gz && \
    tar -xzf openjdk-27-ea+37_linux-x64_bin.tar.gz -C /usr/lib/jvm && \
    rm openjdk-27-ea+37_linux-x64_bin.tar.gz && \
    mv /usr/lib/jvm/jdk-27 /usr/lib/jvm/java-27-openjdk-amd64

# Set JAVA_HOME to JDK 21 as default
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /workspace

COPY . .

CMD ["bash", "run.sh"]