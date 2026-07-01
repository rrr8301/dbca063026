FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    nodejs \
    npm \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Maven (latest version available)
RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz \
    && tar xzvf apache-maven-3.9.4-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.9.4/bin/mvn /usr/bin/mvn \
    && rm apache-maven-3.9.4-bin.tar.gz

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure Maven settings file is available
RUN mkdir -p /app/.mvn && touch /app/.mvn/settings.xml

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]