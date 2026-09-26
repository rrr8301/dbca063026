FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=/usr/share/zoneinfo/America/Los_Angeles

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn

WORKDIR /app

COPY repo/ /app/

RUN yarn install --frozen-lockfile && \
    yarn --cwd compiler install --frozen-lockfile

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
