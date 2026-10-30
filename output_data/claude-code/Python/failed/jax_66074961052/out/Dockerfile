FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y libssl-dev build-essential curl wget git && \
    rm -rf /var/lib/apt/lists/*

RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt update && \
    apt install -y python3.14 python3.14-venv python3.14-dev && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

RUN python -m ensurepip --upgrade && \
    python -m pip install --upgrade pip setuptools

WORKDIR /app

COPY repo/ /app/

RUN python -m pip install uv~=0.5.30

RUN uv pip install --system .[minimum-jaxlib] -r build/test-requirements.txt

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
