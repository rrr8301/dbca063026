FROM node:14.21.3

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY repo/ /app/

RUN npm ci --ignore-scripts

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
