FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3-pip \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN python3.12 -m pip install --upgrade --break-system-packages pip setuptools wheel

WORKDIR /app

COPY repo/ /app/

RUN pip install --break-system-packages -r requirements-dev.txt

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
