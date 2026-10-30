FROM golang:1.22

ENV DEBIAN_FRONTEND=noninteractive
ENV GOTOOLCHAIN=auto

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN go version && \
    git config --global url."https://github.com/".insteadOf git://github.com/ && \
    git submodule update --init --recursive --depth 1 2>&1 | tail -20

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
