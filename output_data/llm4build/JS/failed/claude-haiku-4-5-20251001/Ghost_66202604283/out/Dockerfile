FROM ubuntu:22.04

# Set timezone to America/New_York (non-interactive)
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.18.0
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs=22.18.0-1nodesource1 && \
    rm -rf /var/lib/apt/lists/*

# Install yarn globally
RUN npm install -g yarn

# Set environment variables
ENV FORCE_COLOR=1 \
    NODE_ENV=testing \
    DB=sqlite3 \
    database__connection__filename=/dev/shm/ghost-test.db

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install project dependencies
RUN yarn install --frozen-lockfile

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]