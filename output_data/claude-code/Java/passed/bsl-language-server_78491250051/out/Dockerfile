FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate UTF-8 locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Install Java 21 (OpenJDK)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Verify Java installation
RUN java -version

# Set up working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

ENTRYPOINT ["/run.sh"]
