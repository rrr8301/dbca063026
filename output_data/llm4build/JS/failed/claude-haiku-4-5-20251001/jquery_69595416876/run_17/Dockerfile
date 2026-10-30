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
    chromium-chromedriver \
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

# Set Chromium binary path
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROMEDRIVER_BIN=/usr/bin/chromedriver

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install npm dependencies using npm ci (respects package-lock.json)
RUN npm ci

# Verify ChromeDriver and Chromium are available
RUN which chromium-browser && chromium-browser --version && \
    which chromedriver && chromedriver --version

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]