# Use an official Golang image as a parent image
FROM golang:1.26.1

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the workspace
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the entire project into the workspace
COPY . .

# Install make utility
RUN apt-get update && apt-get install -y make

# Ensure run.sh is executable
RUN chmod +x run.sh

# Run the tests
CMD ["./run.sh"]