FROM golang:1.25.0-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBUG=true
ENV GOFLAGS=-trimpath
ENV GOTOOLCHAIN=local
ENV GOPROXY=direct
ENV GOSUMDB=off

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
