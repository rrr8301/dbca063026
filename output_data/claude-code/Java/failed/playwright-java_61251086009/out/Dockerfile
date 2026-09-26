FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BROWSER=firefox
ENV PW_MAX_RETRIES=3

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 21 (adopt distribution)
RUN apt-get update && apt-get install -y openjdk-21-jdk && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

# Download drivers
RUN bash scripts/download_driver.sh

# Build & Install
RUN mvn -B install -D skipTests --no-transfer-progress

# Install browsers
RUN mvn exec:java -e -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="install --with-deps" -f playwright/pom.xml --no-transfer-progress

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
