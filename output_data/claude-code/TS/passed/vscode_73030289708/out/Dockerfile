FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NPM_ARCH=x64
ENV VSCODE_ARCH=x64
ENV VSCODE_QUALITY=oss
ENV npm_config_arch=x64
ENV ELECTRON_SKIP_BINARY_DOWNLOAD=1
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    curl \
    git \
    wget \
    python3 \
    python3-dev \
    xvfb \
    libgtk-3-0 \
    libxkbfile-dev \
    libkrb5-dev \
    libgbm1 \
    rpm \
    bubblewrap \
    socat \
    libx11-dev \
    libx11-xcb-dev \
    libnotify-bin \
    libfreetype6 \
    libfontconfig1 \
    fontconfig \
    fonts-dejavu \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.22.1
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs=22.22.1-1nodesource1 && \
    rm -rf /var/lib/apt/lists/*

# Setup X server
RUN cp /dev/null /etc/init.d/xvfb && chmod +x /etc/init.d/xvfb

# Create app directory
WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install npm dependencies
RUN npm ci \
    && npm run postinstall

# Download Electron and Playwright
RUN npm exec -- npm-run-all2 -lp "electron $VSCODE_ARCH" "playwright-install"

# Transpile client and extensions
RUN npm run gulp transpile-client-esbuild transpile-extensions

# Build integration tests
RUN npm run gulp \
    compile-extension:configuration-editing \
    compile-extension:css-language-features-server \
    compile-extension:emmet \
    compile-extension:git \
    compile-extension:github-authentication \
    compile-extension:html-language-features-server \
    compile-extension:ipynb \
    compile-extension:notebook-renderers \
    compile-extension:json-language-features-server \
    compile-extension:markdown-language-features \
    compile-extension-media \
    compile-extension:microsoft-authentication \
    compile-extension:typescript-language-features \
    compile-extension:vscode-api-tests \
    compile-extension:vscode-colorize-tests \
    compile-extension:vscode-colorize-perf-tests \
    compile-extension:vscode-test-resolver

# Compile Copilot extension
RUN npm --prefix extensions/copilot run compile

# Compile smoke tests
RUN cd test/smoke && npm run compile

# Compile extensions for smoke tests
RUN npm run gulp compile-extension-media

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Create crash directory
RUN mkdir -p .build/crashes

ENTRYPOINT ["/run.sh"]
