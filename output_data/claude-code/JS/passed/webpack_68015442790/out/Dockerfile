FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn@1.22.22

WORKDIR /app

COPY repo/ /app/

RUN yarn --frozen-lockfile

RUN yarn link --frozen-lockfile || true

RUN yarn link webpack --frozen-lockfile

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
