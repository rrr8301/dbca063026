FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PY_COLORS=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    redis-server \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:$PATH"

RUN uv python install 3.13

WORKDIR /app

COPY repo/ /app/

RUN uv sync --locked

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
