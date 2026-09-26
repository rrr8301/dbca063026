FROM alpine:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache \
    build-base \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    cmake \
    ninja \
    git \
    linux-headers

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
