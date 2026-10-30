# Use the official Golang image as the base image
FROM golang:1.20

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN sed -i 's/1.24.0/1.20/' go.mod && go mod download

# Copy the rest of the application source code
COPY . .

# Build the Go application
RUN go build -o my-go-app

# Command to run the executable
CMD ["./my-go-app"]