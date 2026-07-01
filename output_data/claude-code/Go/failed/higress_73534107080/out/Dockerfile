FROM golang:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPROXY=https://proxy.golang.org,direct

RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN git submodule update --init

RUN chmod +x /app/tools/hack/prebuild.sh && \
    /app/tools/hack/prebuild.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
