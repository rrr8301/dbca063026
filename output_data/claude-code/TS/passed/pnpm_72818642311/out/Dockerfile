FROM node:22.13.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global core.autocrlf false && \
    git config --global user.name "xyz" && \
    git config --global user.email "x@y.z"

WORKDIR /app

COPY repo/ /app/

RUN curl -fsSL https://get.pnpm.io/install.sh | bash - && \
    export PNPM_HOME="/root/.local/share/pnpm" && \
    export PATH="$PNPM_HOME/bin:$PATH" && \
    pnpm --version

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME/bin:$PATH"

RUN npm --version

RUN node --version

RUN pnpm install

RUN pnpm compile-only && pnpm prepare-fixtures

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
