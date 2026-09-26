# Dockerfile
FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN apt-get update && apt-get install -y python3.12 python3.12-venv python3.12-dev

# Install Java 17 (Zulu)
RUN wget -qO- https://cdn.azul.com/zulu/bin/zulu17.32.13-ca-jdk17.0.2-linux_amd64.deb -O zulu17.deb && \
    apt-get install -y ./zulu17.deb && \
    rm zulu17.deb

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]