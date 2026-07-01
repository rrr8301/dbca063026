FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HSM_ENABLED=true
ENV HSM_LIBRARY=/usr/lib/softhsm/libsofthsm2.so
ENV HSM_TOKEN_LABEL=hydra
ENV HSM_PIN=1234

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    softhsm2 \
    opensc \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/golang && \
    curl -sL https://go.dev/dl/go1.26.3.linux-amd64.tar.gz -o /tmp/golang/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/golang/go.tar.gz && \
    rm -rf /tmp/golang

ENV PATH=/usr/local/go/bin:$PATH

WORKDIR /app

COPY repo/ /app/

RUN rm -rf /var/lib/softhsm/tokens && \
    mkdir -p /var/lib/softhsm/tokens && \
    chmod -R a+rwx /var/lib/softhsm && \
    chmod a+rx /etc/softhsm && \
    chmod a+r /etc/softhsm/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
