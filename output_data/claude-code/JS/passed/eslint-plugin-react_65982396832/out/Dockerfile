FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

ENV NVM_DIR="/root/.nvm"

RUN bash -c 'source $NVM_DIR/nvm.sh && \
    nvm install 23 && \
    nvm use 23 && \
    npm install -g npm@latest'

WORKDIR /app

COPY repo/ /app/

RUN bash -c 'source $NVM_DIR/nvm.sh && nvm use 23 && npm install'

RUN bash -c 'source $NVM_DIR/nvm.sh && nvm use 23 && npm install --no-save "eslint@8" "@typescript-eslint/parser@6" "babel-eslint@10"'

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/bin/bash", "-c", "source $NVM_DIR/nvm.sh && nvm use 23 && /run.sh"]
