FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    chromium-browser \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install global npm packages
RUN npm install -g eslint@8.57.0

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create postgres user and directories
RUN mkdir -p /var/run/postgresql && \
    chown postgres:postgres /var/run/postgresql && \
    chmod 2775 /var/run/postgresql && \
    mkdir -p /var/log/postgresql && \
    chown postgres:postgres /var/log/postgresql

# Initialize PostgreSQL database cluster
RUN sudo -u postgres /usr/lib/postgresql/*/bin/initdb -D /var/lib/postgresql/*/main 2>/dev/null || true

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]