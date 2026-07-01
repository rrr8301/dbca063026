FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    openjdk-8-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.6
RUN mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz | \
    tar -xz -C /opt/maven --strip-components=1 && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn

# Set JAVA_HOME to JDK 17 (for Maven runtime)
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]