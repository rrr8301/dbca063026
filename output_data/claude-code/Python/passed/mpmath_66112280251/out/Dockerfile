FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTEST_ADDOPTS="-n auto"

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN pip install --upgrade setuptools pip
RUN pip install --upgrade '.[develop,gmpy2,gmp,ci]'

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
