FROM node:24.6.0

ENV DEBIAN_FRONTEND=noninteractive \
    PUPPETEER_SKIP_DOWNLOAD="true" \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="true"

RUN npm install -g pnpm@latest

WORKDIR /app
COPY repo/ /app/

RUN pnpm install --frozen-lockfile

RUN pnpm build --filter @langchain/core

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
