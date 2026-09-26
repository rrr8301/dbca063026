FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOTRACEBACK=single
ENV TEST_DOCKER=0
ENV TEST_FUSE=0
ENV TEST_VERBOSE=1
ENV GIT_PAGER=cat
ENV IPFS_CHECK_RCMGR_DEFAULTS=1

RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    zsh \
    jq \
    ca-certificates

RUN wget -q https://go.dev/dl/go1.26.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.2.linux-amd64.tar.gz && \
    rm go1.26.2.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
