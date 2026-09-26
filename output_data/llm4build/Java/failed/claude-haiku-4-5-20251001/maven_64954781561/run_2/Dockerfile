FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    openjdk-21-jdk \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Maven 3.9.6
RUN mkdir -p /opt/maven && \
    wget -q https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar xzf /tmp/maven.tar.gz -C /opt/maven --strip-components 1 && \
    rm /tmp/maven.tar.gz && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn

ENV PATH=/opt/maven/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh, convert line endings, and make it executable
COPY run.sh /workspace/run.sh
RUN dos2unix /workspace/run.sh && chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]