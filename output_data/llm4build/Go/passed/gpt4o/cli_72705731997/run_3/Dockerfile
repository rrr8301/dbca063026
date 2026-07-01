# Use the official Golang image as the base image
FROM golang:1.20

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./

# Modify the go.mod file to use a compatible Go version
RUN sed -i 's/1.26.1/1.20/' go.mod

# Remove the unknown directive if necessary
RUN sed -i '/toolchain/d' go.mod

RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the Go application
RUN go build -o myapp ./cmd/gh

# Command to run the application
CMD ["./myapp"]