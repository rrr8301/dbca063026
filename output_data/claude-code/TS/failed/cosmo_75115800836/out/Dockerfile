FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CI=true
ENV DO_NOT_TRACK=1

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    build-essential \
    python3 \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm@9.12.3

# Install OpenJDK 21 (compatible with Keycloak)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install PostgreSQL server and client
RUN apt-get update && apt-get install -y \
    postgresql \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Install Redis
RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Install buf for code generation
RUN curl -sSL https://github.com/bufbuild/buf/releases/download/v1.32.2/buf-Linux-x86_64.tar.gz | tar -xz -C /usr/local && \
    mv /usr/local/buf/bin/buf /usr/local/bin/ && \
    rm -rf /usr/local/buf

WORKDIR /app

COPY repo/ /app/

# Create directory for PostgreSQL
RUN mkdir -p /var/run/postgresql && chown postgres:postgres /var/run/postgresql

# Copy and setup run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
