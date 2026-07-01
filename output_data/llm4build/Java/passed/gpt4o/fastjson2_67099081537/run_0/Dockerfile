# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 21
RUN wget -qO- https://cdn.azul.com/zulu/bin/zulu21.28.85-ca-jdk21.0.0-linux_amd64.deb -O zulu-jdk.deb && \
    apt-get install -y ./zulu-jdk.deb && \
    rm zulu-jdk.deb

# Create work directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Copy the run.sh script and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set the entrypoint to run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]