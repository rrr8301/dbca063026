# Use a valid Golang image version
FROM golang:1.20

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files to the workspace
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the rest of the application code to the workspace
COPY . .

# Build the Go app for the correct architecture
RUN GOOS=linux GOARCH=amd64 go build -o main .

# Ensure the binary has execute permissions
RUN chmod +x main

# Command to run the executable
CMD ["./main"]