# Reproduce Apache Kafka CI job: build / JUnit tests Java 25

FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Java 25 (Temurin)
RUN mkdir -p /opt/java && \
    curl -fsSL https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse > /tmp/java.tar.gz && \
    tar -xzf /tmp/java.tar.gz -C /opt/java --strip-components=1 && \
    rm /tmp/java.tar.gz

ENV JAVA_HOME=/opt/java
ENV PATH=${JAVA_HOME}/bin:$PATH

# Verify Java installation
RUN java -version && javac -version

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install Python requirements
RUN pip install --no-cache-dir -r .github/scripts/requirements.txt

# Copy and set up the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
