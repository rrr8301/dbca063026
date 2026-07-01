FROM golang:1.26

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
