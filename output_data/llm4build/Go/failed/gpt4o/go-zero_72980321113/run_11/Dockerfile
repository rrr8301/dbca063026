# Use an official Golang runtime as a parent image
FROM golang:1.17

# Set the working directory inside the container
WORKDIR /app

# Copy the Go application source code into the container
COPY . .

# Update the Go version in go.mod to be compatible with Go 1.17
RUN sed -i 's/^go .*/go 1.17/' go.mod

# Ensure dependencies are downloaded
RUN go mod tidy

# Build the Go application
RUN go build -o my-go-app

# Set the entrypoint to the built Go application
ENTRYPOINT ["/app/my-go-app"]