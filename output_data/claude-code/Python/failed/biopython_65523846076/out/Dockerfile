FROM python:3.14-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    gcc \
    g++ \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    libfreetype6-dev \
    libpng-dev \
    pkg-config \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo /app/

RUN python -m pip install --upgrade pip setuptools wheel build

RUN python -m pip install --upgrade --upgrade-strategy eager \
    setuptools wheel coverage \
    numpy!=2.1.0 matplotlib mmtf-python networkx igraph rdflib reportlab scipy \
    black==22.12.0 mypy

RUN CC="gcc -fsanitize=address -fsanitize=undefined -g" python -m pip install .

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
