FROM golang:1.26-alpine

ENV DEBIAN_FRONTEND=noninteractive \
    CGO_ENABLED=0

WORKDIR /app

COPY repo/ /app/

RUN apk add --no-cache git bash

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
