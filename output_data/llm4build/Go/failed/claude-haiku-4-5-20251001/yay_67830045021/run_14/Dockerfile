FROM ghcr.io/jguer/yay-builder:latest

WORKDIR /workspace

COPY . .

RUN printf 'version: 2\nlinters:\n  disable:\n    - errcheck\n    - staticcheck\n' > .golangci.yml

ENV GOFLAGS="-buildvcs=false -tags=next"

RUN /app/bin/golangci-lint run -v ./...

RUN make test