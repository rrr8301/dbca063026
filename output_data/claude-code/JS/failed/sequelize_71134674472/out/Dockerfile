FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  curl \
  gnupg \
  git \
  build-essential \
  python3 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

RUN corepack enable yarn

WORKDIR /app

COPY repo/ /app/

RUN corepack prepare yarn@4.13.0 --activate && \
  yarn install --immutable && \
  yarn build && \
  yarn nx reset

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
