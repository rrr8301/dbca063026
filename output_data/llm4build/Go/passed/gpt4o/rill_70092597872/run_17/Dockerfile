# Use a base image with the required Go version for building
FROM golang:1.25 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files first to leverage Docker cache
COPY go.mod go.sum ./

# Install any required dependencies
RUN go mod download

# Copy all the source files into the container
COPY . .

# Ensure that the Go source files are present
RUN ls -la

# Build the Go application
# Update the path to the correct main package directory
# Assuming the main package is located in a different directory, update the path accordingly
RUN go build -o main ./path/to/your/main/package

# Use the official Golang image as a parent image for running
FROM golang:1.21

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/main .

# Command to run the executable
CMD ["./main"]