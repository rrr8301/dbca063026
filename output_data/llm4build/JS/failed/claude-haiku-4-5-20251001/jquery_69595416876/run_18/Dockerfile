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
    chromium \
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
    libexpat1 \
    libfontconfig1 \
    libfreetype6 \
    libharfbuzz0b \
    libicu74 \
    libjpeg-turbo-progs \
    libpng16-16t64 \
    libwebp7 \
    libxcb-dri3-0 \
    libxcb-present0 \
    libxcb-randr0 \
    libxcb-render0 \
    libxcb-shape0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxcb-xinput0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libstdc++6 \
    libgcc1 \
    libc6 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm installation
RUN node --version && npm --version

# Find the actual Chromium binary path
RUN which chromium || which chromium-browser || echo "Chromium not found in PATH"

# Set Chromium binary path (chromium package installs to /usr/bin/chromium)
ENV CHROME_BIN=/usr/bin/chromium

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install npm dependencies using npm ci (respects package-lock.json)
RUN npm ci

# Install ChromeDriver via npm
RUN npm install --save-dev chromedriver

# Verify Chromium is available
RUN test -f $CHROME_BIN && $CHROME_BIN --version || echo "Warning: Chromium binary check"

# Verify ChromeDriver is available
RUN test -f ./node_modules/.bin/chromedriver && ./node_modules/.bin/chromedriver --version || echo "Warning: ChromeDriver check"

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]