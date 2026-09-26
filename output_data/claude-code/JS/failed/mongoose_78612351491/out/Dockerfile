FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV MONGOMS_VERSION=7.0.12
ENV MONGOMS_PREFER_GLOBAL_PATH=1
ENV FORCE_COLOR=true

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

WORKDIR /app
COPY repo/ /app/

RUN npm install

RUN npm run create-separate-require-instance

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
