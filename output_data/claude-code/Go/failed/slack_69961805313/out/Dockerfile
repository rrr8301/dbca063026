FROM golang:1.26-alpine

RUN apk add --no-cache git build-base

WORKDIR /app
COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
