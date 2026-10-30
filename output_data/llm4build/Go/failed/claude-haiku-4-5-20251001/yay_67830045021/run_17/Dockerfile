FROM ghcr.io/jguer/yay-builder:latest

WORKDIR /workspace

COPY . .

RUN printf 'version: 2\nlinters:\n  disable:\n    - errcheck\n    - staticcheck\n' > .golangci.yml

ENV GOFLAGS="-buildvcs=false -tags=next"

# Download dependencies
RUN go mod download

# Run linting
RUN /app/bin/golangci-lint run -v ./...

# Run all tests without skipping, serially to avoid race conditions
RUN go test -p 1 -v ./...