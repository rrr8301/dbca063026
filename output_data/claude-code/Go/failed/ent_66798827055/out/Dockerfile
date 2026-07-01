FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    golang-1.23 \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/go-1.23/bin:$PATH"

WORKDIR /app
COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
