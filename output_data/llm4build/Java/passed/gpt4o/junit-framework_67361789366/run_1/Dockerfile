FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install GraalVM
RUN wget -q --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 -t 0 \
    https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.0/graalvm-ce-java21-linux-amd64-21.3.0.tar.gz \
    && tar -xzf graalvm-ce-java21-linux-amd64-21.3.0.tar.gz -C /opt \
    && rm graalvm-ce-java21-linux-amd64-21.3.0.tar.gz

# Set GraalVM as the default Java
ENV JAVA_HOME=/opt/graalvm-ce-java21-21.3.0
ENV PATH="$JAVA_HOME/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]