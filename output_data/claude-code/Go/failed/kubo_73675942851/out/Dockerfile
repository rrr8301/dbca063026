FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    zsh \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://go.dev/dl/go1.26.2.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH=/usr/local/go/bin:$PATH \
    GO111MODULE=on \
    GOTRACEBACK=single \
    TEST_DOCKER=0 \
    TEST_FUSE=0 \
    TEST_VERBOSE=1 \
    GIT_PAGER=cat \
    IPFS_CHECK_RCMGR_DEFAULTS=1

WORKDIR /app

COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
