FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Setup corepack and pnpm
RUN npm i -g corepack@latest && corepack enable

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install dependencies
RUN make install

# Run i18n build
RUN pnpm --filter @plone/volto i18n

# Run the tests
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
