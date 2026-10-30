FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VSCODE_QUALITY=oss
ENV VSCODE_ARCH=x64
ENV NPM_ARCH=x64
ENV GITHUB_TOKEN=""

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    xvfb \
    libgtk-3-0 \
    libxkbfile-dev \
    libkrb5-dev \
    libgbm1 \
    rpm \
    python3 \
    python3-distutils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN npm ci --no-optional \
    --ignore-scripts \
    && npm run gulp transpile-client-esbuild transpile-extensions

RUN npm exec -- npm-run-all2 -lp "electron x64" "playwright-install" || true

RUN mkdir -p .build/crashes

RUN cp build/azure-pipelines/linux/xvfb.init /etc/init.d/xvfb && \
    chmod +x /etc/init.d/xvfb

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
