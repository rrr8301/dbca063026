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
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Install Maven and JDK 25 (temurin distribution)
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh, convert line endings, and make it executable
COPY run.sh /workspace/run.sh
RUN dos2unix /workspace/run.sh && chmod +x /workspace/run.sh

# Build all modules first to ensure dependencies are available
RUN mvn clean install -DskipTests -Drat.skip=true -Dlicense.skip=true -B -nsu

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]