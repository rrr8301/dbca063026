FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/nodejs && \
    curl -fsSL https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-x64.tar.xz | tar xJ -C /opt/nodejs --strip-components=1 && \
    ln -s /opt/nodejs/bin/node /usr/local/bin/node && \
    ln -s /opt/nodejs/bin/npm /usr/local/bin/npm && \
    ln -s /opt/nodejs/bin/npx /usr/local/bin/npx

WORKDIR /app

COPY repo/ /app/

RUN npm install -D typescript@4 --force && \
    npm install --ignore-scripts && \
    npm install -D --no-save cssnano@^6 --force

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
