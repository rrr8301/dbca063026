FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3.12 \
    python3.12-dev \
    python3-pip \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN cd /app && git submodule update --init --recursive

RUN python3.12 -m pip install -r requirements/build_requirements.txt --break-system-packages && \
    python3.12 -m pip install -r requirements/test_requirements.txt --break-system-packages

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
