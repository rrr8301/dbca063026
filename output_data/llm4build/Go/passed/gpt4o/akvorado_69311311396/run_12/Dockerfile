# Use an official Golang image as a parent image
FROM golang:1.20

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the workspace
COPY go.mod go.sum ./

# Remove unsupported directives from go.mod
RUN sed -i '/^toolchain/d' go.mod && sed -i '/^tool/d' go.mod

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod tidy || true

# Install necessary tools, skipping the problematic package
RUN go install github.com/frapposelli/wwhrd@latest \
    && go install github.com/mgechev/revive@latest \
    && go install github.com/mna/pigeon@latest \
    && go install github.com/planetscale/vtprotobuf/cmd/protoc-gen-go-vtproto@latest \
    && go install go.uber.org/mock/mockgen@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install gotest.tools/gotestsum@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest

# Copy the rest of the application code to the workspace
COPY . .

# Build the Go app
RUN make

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./bin/akvorado", "version"]