FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOCOVERDIR="coverage"

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    postgresql-client \
    postgresql \
    postgresql-contrib \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://go.dev/dl/go1.24.4.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz && \
    rm go1.24.4.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV PATH="$GOPATH/bin:$PATH"

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p $GOCOVERDIR

# Initialize git submodules
RUN git config --global url."https://github.com/".insteadOf "git://github.com/" && \
    git config submodule.internal/embeddocs/website.url https://github.com/inngest/website.git && \
    git submodule update --init --recursive

RUN go install ./vendor/github.com/Songmu/gotesplit/cmd/gotesplit

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
