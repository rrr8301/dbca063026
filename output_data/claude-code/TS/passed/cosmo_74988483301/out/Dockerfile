FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    CI=true \
    DO_NOT_TRACK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    build-essential \
    python3 \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

# Install Node 22.22.2
RUN curl -fsSL https://nodejs.org/dist/v22.22.2/node-v22.22.2-linux-x64.tar.xz -o node.tar.xz && \
    tar -xJf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz

# Install pnpm 9
RUN npm install -g pnpm@9

WORKDIR /app

COPY repo/ /app/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Generate code (including protobuf)
RUN pnpm buf generate --template buf.ts.gen.yaml

# Build
RUN pnpm run --filter ./composition --filter ./connect --filter ./shared build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
