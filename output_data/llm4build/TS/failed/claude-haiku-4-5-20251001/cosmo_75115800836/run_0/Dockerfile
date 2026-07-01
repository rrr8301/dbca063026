FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS) and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists/*

# Install Java 20.0.2 (Zulu)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    && wget -q https://cdn.azul.com/zulu/bin/zulu20.0.2-ca-jdk20.0.2-linux_x64.tar.gz -O /tmp/zulu.tar.gz \
    && tar -xzf /tmp/zulu.tar.gz -C /opt \
    && rm /tmp/zulu.tar.gz \
    && ln -s /opt/zulu20.0.2-ca-jdk20.0.2-linux_x64/bin/java /usr/local/bin/java \
    && ln -s /opt/zulu20.0.2-ca-jdk20.0.2-linux_x64/bin/javac /usr/local/bin/javac \
    && rm -rf /var/lib/apt/lists/*

# Install buf (protobuf code generator)
RUN curl -sSL https://github.com/bufbuild/buf/releases/download/v1.28.1/buf-Linux-x86_64 -o /usr/local/bin/buf && \
    chmod +x /usr/local/bin/buf

# Set JAVA_HOME
ENV JAVA_HOME=/opt/zulu20.0.2-ca-jdk20.0.2-linux_x64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]