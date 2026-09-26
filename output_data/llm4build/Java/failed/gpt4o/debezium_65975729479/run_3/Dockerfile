FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.8 or newer
RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.tar.gz \
    && tar xzvf apache-maven-3.9.8-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.9.8/bin/mvn /usr/bin/mvn \
    && rm apache-maven-3.9.8-bin.tar.gz

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]