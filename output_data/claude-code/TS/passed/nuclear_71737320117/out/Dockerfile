FROM node:24-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV DO_NOT_TRACK=1

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libwebkit2gtk-4.1-dev \
    libappindicator3-dev \
    librsvg2-dev \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env

ENV PATH="/root/.cargo/bin:${PATH}"

RUN npm install -g pnpm

WORKDIR /app

COPY repo/ /app/

RUN pnpm install --frozen-lockfile

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
