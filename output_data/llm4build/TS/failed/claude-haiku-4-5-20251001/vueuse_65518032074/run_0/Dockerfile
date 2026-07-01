FROM node:20-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install system dependencies for Playwright and build tools
RUN apk add --no-cache \
    git \
    build-essential \
    python3 \
    py3-pip \
    curl \
    wget \
    ca-certificates \
    bash \
    # Playwright dependencies
    chromium \
    firefox \
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
    libpango-gobject-0

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