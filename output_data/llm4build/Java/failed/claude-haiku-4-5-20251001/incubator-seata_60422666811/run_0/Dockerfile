FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Update package manager and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (for console-fe webpack builds)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 8
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    && wget -q https://cdn.azul.com/zulu/bin/zulu8.76.0.17-ca-jdk8.0.402-linux_x64.tar.gz -O /tmp/zulu-jdk8.tar.gz \
    && mkdir -p /usr/local/java \
    && tar -xzf /tmp/zulu-jdk8.tar.gz -C /usr/local/java \
    && rm /tmp/zulu-jdk8.tar.gz \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/local/java/zulu8.76.0.17-ca-jdk8.0.402-linux_x64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Redis and Nacos (for services)
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]