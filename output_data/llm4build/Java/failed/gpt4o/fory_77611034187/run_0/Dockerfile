FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 17
RUN wget https://download.java.net/java/GA/jdk17/0d483a095d624c4f9b4d7a3b1c8e1f8c/35/GPL/openjdk-17_linux-x64_bin.tar.gz \
    && tar -xzf openjdk-17_linux-x64_bin.tar.gz -C /opt \
    && rm openjdk-17_linux-x64_bin.tar.gz \
    && ln -s /opt/jdk-17/bin/java /usr/bin/java

# Install Python 3.8
RUN apt-get update && apt-get install -y python3.8 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN wget https://www-us.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz \
    && tar -xzf apache-maven-3.8.6-bin.tar.gz -C /opt \
    && rm apache-maven-3.8.6-bin.tar.gz \
    && ln -s /opt/apache-maven-3.8.6/bin/mvn /usr/bin/mvn

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]