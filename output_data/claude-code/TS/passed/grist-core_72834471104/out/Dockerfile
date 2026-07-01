FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    # Basic tools
    curl wget git build-essential unzip \
    # Python (ubuntu 24.04 has python 3.12 by default, but we'll use what's available)
    python3 python3-venv python3-dev python3-pip \
    # Node.js dependencies
    ca-certificates gnupg lsb-release \
    # For minio and storage
    sqlite3 \
    # PostgreSQL
    postgresql postgresql-contrib postgresql-client \
    # Redis
    redis-server redis-tools \
    # Chrome and dependencies
    chromium-browser chromium-chromedriver \
    # Additional build dependencies
    libssl-dev libffi-dev zlib1g-dev \
    # For gvisor
    apparmor \
    # git and other tools
    sudo \
    # System dependencies
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x from NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install gvisor runsc
RUN wget -q https://gvisor.dev/archive/2024.q2/runsc && \
    chmod +x runsc && \
    mv runsc /usr/bin/runsc || true

WORKDIR /app

COPY repo/ /app/

# Initialize PostgreSQL data directory
RUN sudo -u postgres /usr/lib/postgresql/*/bin/initdb -D /var/lib/postgresql/16/main || true

# Install Python dependencies using system python3
RUN python3 -m venv sandbox_venv3 && \
    . sandbox_venv3/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install virtualenv && \
    yarn run install:python

# Install Node.js dependencies
RUN yarn install

# Build Node.js code
RUN yarn run build

# Install Chrome driver for tests (using system chromedriver or download if needed)
RUN buildtools/install_chrome_for_tests.sh -y || true

# Create necessary directories for tests
RUN mkdir -p /tmp/test-logs/webdriver /var/run/redis /var/run/postgresql /var/run/minio

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
