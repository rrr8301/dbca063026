FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    expect \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://golang.org/dl/go1.26.1.linux-amd64.tar.gz | tar -xz -C /usr/local

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
