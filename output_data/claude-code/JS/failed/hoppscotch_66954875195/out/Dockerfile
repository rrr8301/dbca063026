FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm 10
RUN npm install -g pnpm@10

WORKDIR /app

COPY repo/ /app/

# Set environment variables for dependency installation
ENV DATABASE_URL=postgresql://postgres:testpass@localhost:5432/hoppscotch
ENV DATA_ENCRYPTION_KEY="12345678901234567890123456789012"

# Install dependencies
RUN pnpm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
