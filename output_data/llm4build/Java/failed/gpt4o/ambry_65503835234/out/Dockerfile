FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    mysql-server \
    npm \
    curl \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Azurite
RUN npm install -g azurite

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure gradlew has execute permissions
RUN chmod +x ./gradlew

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]