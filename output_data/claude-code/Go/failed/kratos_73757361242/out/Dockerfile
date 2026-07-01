FROM golang:1.22-jammy

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    sudo \
    gnupg \
    lsb-release \
    unzip \
    jq \
    netcat \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL repository and install PostgreSQL 18
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-18 postgresql-contrib-18 && \
    rm -rf /var/lib/apt/lists/*

# Install MySQL 8.0
RUN apt-get update && apt-get install -y \
    mysql-server && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js v16.19.0
RUN curl -fsSL https://nodejs.org/dist/v16.19.0/node-v16.19.0-linux-x64.tar.xz -o node.tar.xz && \
    tar -xf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz && \
    node --version && npm --version

# Install CockroachDB
RUN curl -fsSL https://binaries.cockroachdb.com/cockroach-latest.linux-amd64.tgz -o cockroach.tgz && \
    tar -xf cockroach.tgz && \
    mv cockroach-latest.linux-amd64/cockroach /usr/local/bin/cockroach && \
    rm -rf cockroach.tgz cockroach-latest.linux-amd64 && \
    cockroach version

WORKDIR /app
COPY repo/ /app/

# Install project dependencies
RUN go mod download
RUN npm ci

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
