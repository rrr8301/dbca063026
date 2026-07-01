# Use the official Golang image as a parent image
FROM golang:1.20

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go application code into the container
COPY . .

# Install Go dependencies
RUN go mod tidy

# Build the Go application
RUN go build -o main .

# Command to run the executable
CMD ["./main"]