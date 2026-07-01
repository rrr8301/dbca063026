FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js 11.15
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN bash -i -c "nvm install 11.15 && nvm use 11.15"

# Set up PATH to include nvm
ENV PATH=/root/.nvm/versions/node/v11.15.0/bin:$PATH

WORKDIR /app
COPY repo/ /app/

# Install mocha@8.4.0
RUN npm install --save-dev mocha@8.4.0

# Install dependencies
RUN npm install

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
