# Use an official Golang image as a parent image
FROM golang:1.20

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files to the workspace
COPY go.mod go.sum ./

# Correct the Go version in go.mod if necessary
RUN sed -i 's/go 1.24.2/go 1.20/' go.mod

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the rest of the application code to the workspace
COPY . .

# Ensure the Go version in go.mod matches the installed Go version
RUN sed -i 's/go 1.24.2/go 1.20/' go.mod

# Build the Go app
RUN go build -o main .

# Command to run the executable
CMD ["./main"]