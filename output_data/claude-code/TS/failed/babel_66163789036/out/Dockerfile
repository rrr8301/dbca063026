FROM node:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    python3 \
    make \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn

WORKDIR /app

COPY repo/ /app/

RUN yarn install

RUN make -j build-standalone-ci \
    && node ./scripts/pack-script.ts \
    && make generate-readme \
    && node scripts/generators/npm-ignore.ts \
    && node scripts/cleanup-fixtures.ts

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
