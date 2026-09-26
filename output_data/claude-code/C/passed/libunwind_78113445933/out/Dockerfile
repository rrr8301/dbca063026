FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      git \
      autoconf \
      automake \
      libtool \
      make \
      g++-14-arm-linux-gnueabi \
      qemu-user \
      abigail-tools

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
