FROM golang:latest

ENV GOPATH=/workspace
ENV PATH=${GOPATH}/bin:/usr/local/go/bin:${PATH}

RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${GOPATH}/src/github.com/go-chi/chi
COPY repo/ ${GOPATH}/src/github.com/go-chi/chi/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
