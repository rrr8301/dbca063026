# Use the official Golang image as a parent image
FROM golang:1.21

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
RUN go build -o main ./path/to/your/main/package

# Command to run the executable
CMD ["./main"]