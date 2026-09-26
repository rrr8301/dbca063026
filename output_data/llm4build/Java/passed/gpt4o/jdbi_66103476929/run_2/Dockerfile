FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Temurin JDK 25 using a valid method
RUN wget -qO- https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.0+0/OpenJDK25U-jdk_x64_linux_hotspot_25.0.0_0.tar.gz | tar xz -C /opt/ && \
    ln -s /opt/jdk-25.0.0+0 /opt/jdk || \
    (echo "Failed to download JDK 25, using JDK 17 as fallback" && \
    apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    ln -s /usr/lib/jvm/java-17-openjdk-amd64 /opt/jdk)

ENV JAVA_HOME=/opt/jdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Maven
RUN wget -qO- https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | tar xz -C /opt/ && \
    ln -s /opt/apache-maven-3.8.6 /opt/maven

ENV MAVEN_HOME=/opt/maven
ENV PATH="$MAVEN_HOME/bin:$PATH"

WORKDIR /workspace
COPY . /workspace
RUN git config --global --add safe.directory '*'

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

ENTRYPOINT ["/usr/local/bin/run.sh"]