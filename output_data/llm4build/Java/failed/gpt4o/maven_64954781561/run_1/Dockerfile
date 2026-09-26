FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    tar \
    openjdk-21-jdk

# Install Maven 3.9 or later
RUN wget https://downloads.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz -O /tmp/maven.tar.gz && \
    mkdir -p /opt/maven && \
    tar xzf /tmp/maven.tar.gz -C /opt/maven --strip-components=1 && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]