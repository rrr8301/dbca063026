FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NB_KERNEL=python
ENV MPLBACKEND=Agg
ENV SEABORN_DATA=/app/seaborn-data
ENV PYDEVD_DISABLE_FILE_VALIDATION=1

RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    git \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN python3.11 -m pip install --upgrade pip wheel && \
    python3.11 -m pip install .[dev,stats]

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
