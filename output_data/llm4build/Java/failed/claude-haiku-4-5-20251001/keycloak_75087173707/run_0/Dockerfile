FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    sudo \
    build-essential \
    ca-certificates \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 25 (temurin distribution)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]