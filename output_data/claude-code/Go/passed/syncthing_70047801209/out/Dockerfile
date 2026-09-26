FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOMIPS=softfloat
ENV GOARM=6
ENV LOGGER_DISCARD=1
ENV BUILD_USER=builder
ENV BUILD_HOST=github.syncthing.net
ENV TAGS="sqlite_omit_load_extension sqlite_dbstat"
ENV TAGS_LINUX="sqlite_omit_load_extension sqlite_dbstat netgo osusergo"
ENV CGO_ENABLED=1
ENV GOFLAGS="-json"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://go.dev/dl/go1.25.0.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:/root/go/bin:$PATH"

WORKDIR /app
COPY repo/ /app/

RUN go install calmh.dev/go-test-json-to-loki@latest

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
