FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    lsb-release \
    software-properties-common \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Corretto JDK 21
RUN curl -fL https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.tar.gz -o /tmp/corretto.tar.gz && \
    tar -xzf /tmp/corretto.tar.gz -C /opt && \
    rm /tmp/corretto.tar.gz && \
    ln -s /opt/amazon-corretto-21.* /opt/java-21

ENV JAVA_HOME=/opt/java-21
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Maven (use official binary, not distro package)
RUN curl -fL https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -o /tmp/maven.tar.gz && \
    tar -xzf /tmp/maven.tar.gz -C /opt && \
    rm /tmp/maven.tar.gz && \
    ln -s /opt/apache-maven-3.9.6 /opt/maven

ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# Set Maven options (from workflow env)
ENV MAVEN_OPTS="-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]