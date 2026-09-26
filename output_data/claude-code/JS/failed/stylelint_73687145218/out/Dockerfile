FROM node:22

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=2

WORKDIR /app

COPY repo/ /app/

RUN npm install --global npm && \
    npm ci

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
