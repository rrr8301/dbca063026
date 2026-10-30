FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    gnupg \
    ca-certificates \
    redis \
    postgresql-client

# Install OpenJDK 20
RUN wget https://download.java.net/java/GA/jdk20/latest/binaries/openjdk-20_linux-x64_bin.tar.gz && \
    tar -xzf openjdk-20_linux-x64_bin.tar.gz -C /opt && \
    rm openjdk-20_linux-x64_bin.tar.gz && \
    ln -s /opt/jdk-20/bin/java /usr/bin/java

# Install Node.js and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy and set permissions for run.sh
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]