FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    python3 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 25 using nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . $NVM_DIR/nvm.sh && nvm install 25 && nvm use 25

# Set PATH to use the Node installed by nvm
ENV PATH=$NVM_DIR/versions/node/v25.*/bin:$PATH

WORKDIR /app
COPY repo/ /app/

# Install project dependencies
RUN . $NVM_DIR/nvm.sh && npm install

# Install specific versions of eslint, babel-eslint, and typescript-eslint
RUN . $NVM_DIR/nvm.sh && npm install --no-save eslint@9 "@typescript-eslint/parser@8.17" "babel-eslint@8"

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
