FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    chromium-browser \
    chromium-codecs-ffmpeg \
    xvfb \
    libxss1 \
    fonts-liberation \
    xdg-utils \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libasound2t64 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libcairo2 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    ca-certificates \
    dbus \
    dbus-x11 \
    libdbus-1-3 \
    pulseaudio \
    libpulse0 \
    libappindicator3-1 \
    libu2f-udev \
    libvulkan1 \
    libdrm2 \
    libxkbcommon0 \
    libwayland-client0 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm installation
RUN node --version && npm --version

# Get Chromium version and install matching ChromeDriver
RUN CHROMIUM_VERSION=$(chromium-browser --version | awk '{print $NF}') && \
    echo "Chromium version: $CHROMIUM_VERSION" && \
    npm install -g chromedriver@$CHROMIUM_VERSION

# Set Chromium binary path
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage --disable-software-rasterizer --disable-extensions --disable-setuid-sandbox --disable-web-resources --disable-sync --disable-default-apps --disable-plugins --disable-plugin-power-saver --disable-preconnect --disable-background-networking --disable-breakpad --disable-client-side-phishing-detection --disable-component-extensions-with-background-pages --disable-default-apps --disable-hang-monitor --disable-popup-blocking --disable-prompt-on-repost --disable-sync --enable-automation --no-first-run --password-store=basic --use-mock-keychain"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install npm dependencies using npm ci (respects package-lock.json)
RUN npm ci

# Verify ChromeDriver is available
RUN which chromedriver && chromedriver --version

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]