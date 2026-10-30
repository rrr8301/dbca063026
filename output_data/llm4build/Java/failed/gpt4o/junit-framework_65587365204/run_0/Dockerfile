FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install GraalVM
RUN wget -q https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.0/graalvm-ce-java21-linux-amd64-21.3.0.tar.gz \
    && tar -xzf graalvm-ce-java21-linux-amd64-21.3.0.tar.gz -C /opt \
    && rm graalvm-ce-java21-linux-amd64-21.3.0.tar.gz \
    && ln -s /opt/graalvm-ce-java21-21.3.0/bin/* /usr/bin/

# Install JDK 25
RUN wget -q https://download.java.net/java/GA/jdk25/latest/binaries/openjdk-25_linux-x64_bin.tar.gz \
    && tar -xzf openjdk-25_linux-x64_bin.tar.gz -C /opt \
    && rm openjdk-25_linux-x64_bin.tar.gz \
    && ln -s /opt/jdk-25/bin/* /usr/bin/

# Install Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-7.2-bin.zip \
    && unzip gradle-7.2-bin.zip -d /opt \
    && rm gradle-7.2-bin.zip \
    && ln -s /opt/gradle-7.2/bin/gradle /usr/bin/gradle

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]