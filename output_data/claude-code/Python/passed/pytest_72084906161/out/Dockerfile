FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3.11 -m pip install --upgrade pip setuptools wheel

WORKDIR /app

COPY repo/ /app/

RUN python3.11 -m pip install tox

RUN python3.11 -m pip install build

RUN python3.11 -m build --sdist

RUN ls -la dist/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENV PYTEST_ADDOPTS="--color=yes"
ENV CI=true

ENTRYPOINT ["/run.sh"]
