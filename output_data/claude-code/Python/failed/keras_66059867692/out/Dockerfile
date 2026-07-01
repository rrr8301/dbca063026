FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV KERAS_HOME=.github/workflows/config/jax

RUN apt-get update && apt-get -y install \
    build-essential \
    curl \
    git \
    gnupg \
    && git config --global --add safe.directory '*' \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN pip install --upgrade pip setuptools && \
    pip install -r requirements.txt && \
    pip install --no-deps tf_keras

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
