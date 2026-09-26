FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create JVM and Maven directories
RUN mkdir -p /usr/lib/jvm /opt/maven

# Download and install Java 18 from Eclipse Temurin
RUN cd /tmp && \
    curl -fsSL -o temurin-18.tar.gz "https://github.com/adoptium/temurin18-binaries/releases/download/jdk-18.0.2.1%2B1/OpenJDK18U-jdk_x64_linux_hotspot_18.0.2.1_1.tar.gz" && \
    tar -xzf temurin-18.tar.gz -C /usr/lib/jvm/ && \
    rm temurin-18.tar.gz

# Download and install Java 17 from Eclipse Temurin
RUN cd /tmp && \
    curl -fsSL -o temurin-17.tar.gz "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz" && \
    tar -xzf temurin-17.tar.gz -C /usr/lib/jvm/ && \
    rm temurin-17.tar.gz

# Download and install Maven 3.9.12
RUN cd /tmp && \
    curl -fsSL -o maven-3.9.12.tar.gz "https://archive.apache.org/dist/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz" && \
    tar -xzf maven-3.9.12.tar.gz -C /opt/ && \
    rm maven-3.9.12.tar.gz && \
    ln -s /opt/apache-maven-3.9.12 /opt/maven

# Set JAVA_HOME environment variables
ENV JAVA_HOME=/usr/lib/jvm/jdk-18.0.2.1+1
ENV JAVA_HOME_18_X64=/usr/lib/jvm/jdk-18.0.2.1+1
ENV JAVA_HOME_17_X64=/usr/lib/jvm/jdk-17.0.10+7
ENV PATH=$JAVA_HOME/bin:/opt/maven/bin:$PATH

WORKDIR /app

# Copy repo
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
