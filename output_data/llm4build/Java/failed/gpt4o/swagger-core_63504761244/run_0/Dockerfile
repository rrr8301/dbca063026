FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Temurin JDK 17
RUN mkdir -p /opt/java && \
    curl -L -o /tmp/openjdk.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8+7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.8_7.tar.gz && \
    tar -xzf /tmp/openjdk.tar.gz -C /opt/java && \
    rm /tmp/openjdk.tar.gz

# Install Maven
RUN curl -L -o /tmp/apache-maven.tar.gz https://downloads.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
    tar -xzf /tmp/apache-maven.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.8.6 /opt/maven && \
    rm /tmp/apache-maven.tar.gz
ENV PATH="/opt/maven/bin:$PATH"

# Install Gradle
RUN curl -L -o /tmp/gradle.zip https://services.gradle.org/distributions/gradle-7.5-bin.zip && \
    unzip /tmp/gradle.zip -d /opt && \
    ln -s /opt/gradle-7.5 /opt/gradle && \
    rm /tmp/gradle.zip
ENV PATH="/opt/gradle/bin:$PATH"

WORKDIR /workspace
COPY . /workspace
RUN git config --global --add safe.directory '*'

COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

ENTRYPOINT ["/workspace/run.sh"]