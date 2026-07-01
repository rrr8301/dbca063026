FROM ubuntu:24.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 21 (Zulu) from direct download
RUN mkdir -p /opt/jdk21 && \
    cd /tmp && \
    wget -q https://cdn.azul.com/zulu/bin/zulu21.36.17-ca-jdk21.0.4-linux_x64.tar.gz && \
    tar -xzf zulu21.36.17-ca-jdk21.0.4-linux_x64.tar.gz -C /opt/jdk21 --strip-components=1 && \
    rm zulu21.36.17-ca-jdk21.0.4-linux_x64.tar.gz

# Install JDK 25 (Zulu) from direct download
RUN mkdir -p /opt/jdk25 && \
    cd /tmp && \
    wget -q https://cdn.azul.com/zulu/bin/zulu25.28.91-ca-jdk25.0.0-linux_x64.tar.gz && \
    tar -xzf zulu25.28.91-ca-jdk25.0.0-linux_x64.tar.gz -C /opt/jdk25 --strip-components=1 && \
    rm zulu25.28.91-ca-jdk25.0.0-linux_x64.tar.gz

# Install JDK 27 from jdk.java.net
RUN mkdir -p /opt/jdk27 && \
    cd /tmp && \
    wget -q https://download.java.net/java/GA/jdk27/fd2272bbf8d441b8e91c926665a20129/1/GPL/openjdk-27_linux-x64_bin.tar.gz && \
    tar -xzf openjdk-27_linux-x64_bin.tar.gz -C /opt/jdk27 --strip-components=1 && \
    rm openjdk-27_linux-x64_bin.tar.gz

# Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME to JDK 21 by default
ENV JAVA_HOME=/opt/jdk21
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]