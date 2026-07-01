FROM node:24

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY repo/ /app/

RUN npm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
