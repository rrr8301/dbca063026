FROM node:14

WORKDIR /workspace

COPY package.json package-lock.json* /workspace/

COPY run.sh /workspace/run.sh

RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]