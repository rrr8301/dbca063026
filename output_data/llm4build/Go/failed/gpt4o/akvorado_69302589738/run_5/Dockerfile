# Use the official Golang image as a build stage
FROM golang:1.20 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Remove unsupported directives from go.mod
RUN sed -i '/^toolchain/d' go.mod && sed -i '/^tool/d' go.mod

# Download dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the Go application
RUN go build -o ./bin/akvorado ./cmd/akvorado

# Use a minimal base image for the final stage
FROM debian:bullseye-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/bin/akvorado /app/bin/akvorado

# Expose the port the app runs on
EXPOSE 8080

# Command to run the executable
CMD ["/app/bin/akvorado", "version"]