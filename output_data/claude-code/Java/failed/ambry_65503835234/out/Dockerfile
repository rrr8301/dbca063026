FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk-headless \
    mysql-server \
    mysql-client \
    nodejs \
    npm \
    curl \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set up Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy repository
WORKDIR /app
COPY repo/ /app/

# Install Node.js dependencies for Azurite
RUN npm install -g azurite@latest

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
