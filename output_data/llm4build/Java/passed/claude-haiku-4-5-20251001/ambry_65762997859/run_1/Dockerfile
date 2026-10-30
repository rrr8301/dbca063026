FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openjdk-11-jdk \
    mysql-server \
    npm \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18 (for azurite compatibility with nullish coalescing operator)
RUN npm install -g n && n 18.17.0 && npm install -g npm@latest

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make gradlew executable
RUN chmod +x /workspace/gradlew

# Install Azurite globally
RUN npm install -g azurite

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]