FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 (LTS as of the time the job ran)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Setup corepack and enable pnpm
RUN npm i -g --force corepack && corepack enable

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install dependencies
RUN pnpm install

# Run the build and tests
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
