FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 17 from Ubuntu repos (available in Noble)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 18 from Zulu (not available in Ubuntu 24.04 repos)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/java \
    && wget -q https://cdn.azul.com/zulu/bin/zulu18.32.13-ca-jdk18.0.2.1-linux_x64.tar.gz -O /tmp/zulu18.tar.gz \
    && tar -xzf /tmp/zulu18.tar.gz -C /opt/java \
    && rm /tmp/zulu18.tar.gz \
    && ln -s /opt/java/zulu18.32.13-ca-jdk18.0.2.1-linux_x64 /opt/java/jdk18

# Set JAVA_HOME to JDK 18 as primary
ENV JAVA_HOME=/opt/java/jdk18
ENV JAVA_HOME_18_X64=/opt/java/jdk18
ENV JAVA_HOME_17_X64=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Update Maven wrapper SHA-256 checksum to the correct value for Maven 3.9.12
RUN if [ -f .mvn/wrapper/maven-wrapper.properties ]; then \
    sed -i 's/distributionSha256Sum=.*/distributionSha256Sum=305773a68d6ddfd413df58c82b3f8050e89778e777f3a745c8e5b8cbea4018ef/' .mvn/wrapper/maven-wrapper.properties || true; \
    fi

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]