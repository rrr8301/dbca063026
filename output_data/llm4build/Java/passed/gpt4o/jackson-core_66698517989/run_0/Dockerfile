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

# Install Temurin JDK 25
RUN wget https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.0+0/OpenJDK25U-jdk_x64_linux_hotspot_25.0.0_0.tar.gz \
    && tar -xzf OpenJDK25U-jdk_x64_linux_hotspot_25.0.0_0.tar.gz -C /opt/ \
    && rm OpenJDK25U-jdk_x64_linux_hotspot_25.0.0_0.tar.gz
ENV JAVA_HOME=/opt/jdk-25
ENV PATH="$JAVA_HOME/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]