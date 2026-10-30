FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set Java tool options as per workflow
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Duser.timezone=Asia/Shanghai"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 11 (Zulu distribution) - download directly from Azul
RUN mkdir -p /opt/java && \
    curl -fsSL https://cdn.azul.com/zulu/bin/zulu11.72.19-ca-jdk11.0.21-linux_x64.tar.gz -o /tmp/zulu-11.tar.gz && \
    tar -xzf /tmp/zulu-11.tar.gz -C /opt/java && \
    rm /tmp/zulu-11.tar.gz && \
    ln -s /opt/java/zulu11.72.19-ca-jdk11.0.21-linux_x64 /opt/java/zulu-11

# Set JAVA_HOME
ENV JAVA_HOME=/opt/java/zulu-11
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]