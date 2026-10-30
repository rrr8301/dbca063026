FROM node:lts

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY repo/ /app/

RUN npm ci --ignore-scripts

RUN npm run build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
