FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
    build-essential \
    curl \
    git \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global --add safe.directory '*'

WORKDIR /app

COPY repo/ /app/

RUN pip install --upgrade pip setuptools wheel

RUN pip install -r requirements.txt

RUN pip install --no-deps tf_keras

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
