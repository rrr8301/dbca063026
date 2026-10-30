FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=1
ENV PATH="/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
