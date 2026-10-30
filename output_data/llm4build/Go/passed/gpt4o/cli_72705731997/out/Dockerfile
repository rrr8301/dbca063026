# Use the official Golang image as the base image
FROM golang:1.20

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./

# Remove the unknown directive if necessary
RUN sed -i '/toolchain/d' go.mod

# Modify the go.mod file to use a compatible Go version
RUN sed -i 's/^go .*/go 1.20/' go.mod

# Download dependencies
RUN go mod tidy

# Copy the rest of the application source code
COPY . .

# Ensure the build directory exists
RUN mkdir -p ./cmd/gh

# Build the Go application
RUN go build -o myapp ./cmd/gh

# Command to run the application
CMD ["./myapp"]