FROM node:20-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apt-get update && apt-get install -y tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

# Install system dependencies for Playwright and build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3 \
    python3-pip \
    curl \
    wget \
    ca-certificates \
    bash \
    # Playwright dependencies
    chromium \
    firefox-esr \
    dbus \
    libxss1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxkbcommon0 \
    libpangoft2-1.0-0 \
    libxext6 \
    libx11-6 \
    libxcb1 \
    fonts-liberation \
    libnss3 \
    lsb-release \
    xdg-utils \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libexpat1 \
    libgbm1 \
    libpango-1.0-0 \
    libpango-gobject-0 \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository (assumes repo is available locally)
COPY . .

# Install pnpm globally
RUN npm install -g pnpm

# Install @antfu/ni globally
RUN npm install -g @antfu/ni

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]