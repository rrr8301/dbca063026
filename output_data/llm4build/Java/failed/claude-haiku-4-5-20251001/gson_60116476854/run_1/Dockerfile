FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 17 (Temurin)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Verify Java and Maven installation
RUN java -version && mvn -version

# Create working directory
WORKDIR /workspace

# Copy the run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Copy the entire project (pom.xml and source code)
COPY . /workspace/

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]