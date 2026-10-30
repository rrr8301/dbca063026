FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update package manager and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    openjdk-21-jdk \
    openjdk-21-jdk-headless \
    maven \
    nodejs \
    npm \
    yarn \
    g++ \
    gcc \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME explicitly
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Verify Java and Maven installation
RUN java -version && mvn -version

# Create working directory
WORKDIR /workspace

# Copy the repository (assumes the repo is in the build context)
COPY . /workspace/

# Make run.sh executable and set as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]