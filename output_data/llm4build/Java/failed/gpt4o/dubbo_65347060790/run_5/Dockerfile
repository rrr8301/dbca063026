FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 25
# Replace the placeholder URL with the correct URL for Zulu JDK 25
RUN wget -qO- https://cdn.azul.com/zulu/bin/zulu25.0.0-ca-jdk25.0.0-linux_x64.tar.gz | tar -xz -C /opt/ && \
    ln -s /opt/zulu25.0.0-ca-jdk25.0.0-linux_x64 /opt/zulu || \
    (echo "Failed to download Zulu JDK 25, please check the URL or network connection" && exit 1)

ENV JAVA_HOME=/opt/zulu
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