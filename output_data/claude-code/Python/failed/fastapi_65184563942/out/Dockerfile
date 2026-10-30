FROM python:3.13-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_NO_SYNC=true
ENV INLINE_SNAPSHOT_DEFAULT_FLAGS=review
ENV UV_PYTHON=3.13
ENV UV_RESOLUTION=highest
ENV STARLETTE_SRC=starlette-pypi

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/astral-sh/uv/releases/download/0.11.4/uv-x86_64-unknown-linux-gnu.tar.gz | \
    tar xz && mv uv /usr/local/bin/uv && \
    /usr/local/bin/uv --version

WORKDIR /app

COPY repo/ /app/

RUN /usr/local/bin/uv sync --no-dev --group tests --extra all

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
