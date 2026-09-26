FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    python3.11 \
    python3.11-dev \
    python3-pip \
    git \
    wget \
    ca-certificates \
    zlib1g-dev \
    libffi-dev \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3.11 /usr/bin/python

RUN python -m pip install --upgrade pip hatchling

WORKDIR /app

COPY repo/ /app/

RUN python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt

RUN cd bootloader && python waf --tests all && cd ..

RUN python -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl

RUN sh release/build-wheels

RUN python -m pip install --no-index --find-links=dist pyinstaller[completion]

RUN python -m PyInstaller -h

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
