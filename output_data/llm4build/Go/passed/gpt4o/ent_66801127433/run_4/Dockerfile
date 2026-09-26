# Use the official Golang image as the base image
FROM golang:1.24

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application code
COPY . .

# Make the run.sh script executable
RUN chmod +x run.sh

# Run the run.sh script
CMD ["./run.sh"]