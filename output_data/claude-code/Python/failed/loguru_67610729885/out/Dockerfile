FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    git \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN python3.10 -m pip install --upgrade pip

WORKDIR /app

COPY repo/ /app/

RUN python3.10 -m pip install tox

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
