FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TOXENV=py312-sqlite
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    libgeos-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libz-dev \
    libexpat1 \
    python3-distutils-extra \
    python3.12 \
    python3.12-dev \
    python3-pip \
    python3-setuptools \
    git \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN pip3.12 install --break-system-packages -r requirements.txt && \
    pip3.12 install --break-system-packages -r requirements-standalone.txt && \
    pip3.12 install --break-system-packages -r requirements-pubsub.txt && \
    pip3.12 install --break-system-packages -r requirements-dev.txt && \
    pip3.12 install --break-system-packages --upgrade https://github.com/geopython/OWSLib/archive/master.zip && \
    pip3.12 install --break-system-packages tox

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
