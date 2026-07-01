FROM ubuntu:24.04

# Set timezone to avoid interactive prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update package lists and add PostgreSQL repository
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install build dependencies and PostgreSQL 16 (latest available in Ubuntu 24.04)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    postgresql-16 \
    postgresql-server-dev-16 \
    postgresql-contrib-16 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create PostgreSQL data directory and set permissions
RUN mkdir -p /var/run/postgresql && \
    chown postgres:postgres /var/run/postgresql && \
    chmod 2775 /var/run/postgresql && \
    mkdir -p /var/lib/postgresql/16/main && \
    chown postgres:postgres /var/lib/postgresql/16/main && \
    chmod 700 /var/lib/postgresql/16/main

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]