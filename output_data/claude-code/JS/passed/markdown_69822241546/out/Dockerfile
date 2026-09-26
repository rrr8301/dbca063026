FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs=20.19.0-1nodesource1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo /app/

RUN npm install --no-audit --no-fund

RUN npm install -D eslint@10.x @eslint/js@10.x

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
