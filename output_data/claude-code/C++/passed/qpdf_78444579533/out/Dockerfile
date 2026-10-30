FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV QTEST_COLOR=1

RUN apt-get update && apt-get -y install \
    build-essential cmake \
    zlib1g-dev libjpeg-dev libgnutls28-dev libssl-dev \
    zsh \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
