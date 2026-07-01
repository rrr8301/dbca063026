FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 21
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and make run.sh executable with proper line endings
COPY run.sh /workspace/run.sh
RUN dos2unix /workspace/run.sh 2>/dev/null || sed -i 's/\r$//' /workspace/run.sh && \
    chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]