FROM ubuntu:22.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y libssl-dev git curl wget software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.14 (if it were available, but for now, let's assume we use 3.11)
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-venv python3.11-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN python3.11 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install uv~=0.5.30

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

ENTRYPOINT ["/app/run.sh"]