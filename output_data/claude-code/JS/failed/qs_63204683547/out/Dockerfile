FROM node:22.22-bookworm

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY repo/ /app/

RUN npm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
