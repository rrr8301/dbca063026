FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    openjdk-8-jdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.0 or newer
RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz \
    && tar xzvf apache-maven-3.9.0-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.9.0 /opt/maven \
    && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
    && rm apache-maven-3.9.0-bin.tar.gz

# Set environment variables for Java
ENV JAVA_HOME_8=/usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_HOME_17=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME_8/bin:$JAVA_HOME_17/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]