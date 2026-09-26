FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_25.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm

WORKDIR /app
COPY repo/ /app/

RUN cd /app/packages/eslint-config-airbnb-base && \
    npm install

RUN cd /app/packages/eslint-config-airbnb-base && \
    npm install --no-save "eslint@7"

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
