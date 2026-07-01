FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    graphviz \
    git \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Set up Java
RUN apt-get update && apt-get install -y openjdk-21-jdk && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Download and extract Maven
RUN mkdir -p maven-local && \
    curl -L https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz | \
    tar xz -C maven-local --strip-components=1

# Set environment variables
ENV MAVEN_HOME=/app/maven-local
ENV PATH="$MAVEN_HOME/bin:$PATH"

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]